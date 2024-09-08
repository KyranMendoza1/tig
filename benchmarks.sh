#!/bin/bash
set -e

apt-get install jq -y

PLAYER_ID=0x5de35f527176887b1b42a2703ba4d64e62a48de4

declare -A SOLUTIONS_COUNT
declare -A PREVIOUS_SOLUTIONS_COUNT

while true; do
    BLOCK_ID=$(curl -s https://mainnet-api.tig.foundation/get-block | jq -r '.block.id')
    RESP=$(curl -s "https://mainnet-api.tig.foundation/get-benchmarks?block_id=$BLOCK_ID&player_id=$PLAYER_ID")

    BENCHMARKS=$(echo $RESP | jq -c '[.benchmarks[]] | sort_by(.settings.challenge_id, -.details.num_solutions)')

    for BENCHMARK in $(echo $BENCHMARKS | jq -c '.[]'); do
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

        # Update the solution count
        PREVIOUS_COUNT=${SOLUTIONS_COUNT["$CHALLENGE_NAME"]:-0}
        SOLUTIONS_COUNT["$CHALLENGE_NAME"]=$(( ${SOLUTIONS_COUNT["$CHALLENGE_NAME"]:-0} + NUM_SOLUTIONS ))

        # Check if new solutions have been found
        if [ ${SOLUTIONS_COUNT["$CHALLENGE_NAME"]} -gt $PREVIOUS_COUNT ]; then
            echo "New solutions found for $CHALLENGE_NAME: ${SOLUTIONS_COUNT[$CHALLENGE_NAME]}"
        fi
    done

    sleep 60  # Sleep for 1 minute before checking again
done
