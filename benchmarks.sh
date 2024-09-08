#!/bin/bash
set -e
apt-get install jq -y

# Ask for player_id as input
PLAYER_ID=0x5de35f527176887b1b42a2703ba4d64e62a48de4
BLOCK_ID=$(curl -s https://mainnet-api.tig.foundation/get-block | jq -r '.block.id')
RESP=$(curl -s "https://mainnet-api.tig.foundation/get-benchmarks?block_id=$BLOCK_ID&player_id=$PLAYER_ID")

BENCHMARKS=$(echo $RESP | jq -c '[.benchmarks[]] | sort_by(.settings.challenge_id, -.details.num_solutions)')

declare -A SOLUTIONS_COUNT

for BENCHMARK in $(echo $BENCHMARKS | jq -c '.[]'); do
    ID=$(echo $BENCHMARK | jq -r '.id')
    SETTINGS=$(echo $BENCHMARK | jq -c '.settings')
    CHALLENGE_ID=$(echo $BENCHMARK | jq -r '.settings.challenge_id')
    NUM_SOLUTIONS=$(echo $BENCHMARK | jq -r '.details.num_solutions')

    # Map challenge ID to challenge name
    case "$CHALLENGE_ID" in
        "c001")
            CHALLENGE_NAME="Satisfiability"
            ;;
        "c002")
            CHALLENGE_NAME="Vehicle Routing"
            ;;
        "c003")
            CHALLENGE_NAME="Knapsack"
            ;;
        "c004")
            CHALLENGE_NAME="Vector Search"
            ;;
        *)
            CHALLENGE_NAME="Unknown Challenge"
            ;;
    esac

    SOLUTIONS_COUNT["$CHALLENGE_NAME"]=$(( ${SOLUTIONS_COUNT["$CHALLENGE_NAME"]:-0} + NUM_SOLUTIONS ))
done

# Display all the challenges in one line
OUTPUT=""
for CHALLENGE_NAME in "Satisfiability" "Vehicle Routing" "Knapsack" "Vector Search"; do
    OUTPUT+="$CHALLENGE_NAME: ${SOLUTIONS_COUNT[$CHALLENGE_NAME]:-0}  "
done

echo "$OUTPUT"

# Continuously check for new solutions
while true; do
    sleep 5 # Adjust the sleep duration as needed
    NEW_RESP=$(curl -s "https://mainnet-api.tig.foundation/get-benchmarks?block_id=$BLOCK_ID&player_id=$PLAYER_ID")
    NEW_BENCHMARKS=$(echo $NEW_RESP | jq -c '[.benchmarks[]] | sort_by(.settings.challenge_id, -.details.num_solutions)')

    declare -A NEW_SOLUTIONS_COUNT

    for BENCHMARK in $(echo $NEW_BENCHMARKS | jq -c '.[]'); do
        CHALLENGE_ID=$(echo $BENCHMARK | jq -r '.settings.challenge_id')
        NUM_SOLUTIONS=$(echo $BENCHMARK | jq -r '.details.num_solutions')

        case "$CHALLENGE_ID" in
            "c001")
                CHALLENGE_NAME="Satisfiability"
                ;;
            "c002")
                CHALLENGE_NAME="Vehicle Routing"
                ;;
            "c003")
                CHALLENGE_NAME="Knapsack"
                ;;
            "c004")
                CHALLENGE_NAME="Vector Search"
                ;;
            *)
                CHALLENGE_NAME="Unknown Challenge"
                ;;
        esac

        NEW_SOLUTIONS_COUNT["$CHALLENGE_NAME"]=$(( ${NEW_SOLUTIONS_COUNT["$CHALLENGE_NAME"]:-0} + NUM_SOLUTIONS ))
    done

    # Compare with previous results and display if there's any change
    for CHALLENGE_NAME in "Satisfiability" "Vehicle Routing" "Knapsack" "Vector Search"; do
        if [ "${NEW_SOLUTIONS_COUNT[$CHALLENGE_NAME]:-0}" -gt "${SOLUTIONS_COUNT[$CHALLENGE_NAME]:-0}" ]; then
            echo "New solutions found for $CHALLENGE_NAME: ${NEW_SOLUTIONS_COUNT[$CHALLENGE_NAME]} (Previous: ${SOLUTIONS_COUNT[$CHALLENGE_NAME]})"
        fi
    done

    # Update the solutions count for the next iteration
    SOLUTIONS_COUNT=("${NEW_SOLUTIONS_COUNT[@]}")
done
