#!/bin/bash
set -e
apt-get install jq -y
# Ask for player_id as input
PLAYER_ID=0x33cb6150700ca9c00f65db56184c4c321890a82f
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
