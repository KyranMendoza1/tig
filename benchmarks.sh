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
    case $CHALLENGE_ID in
        'c001' | 'c_001' | 'c_001')
            CHALLENGE_NAME="Satisfiability"
            ;;
        'c002' | 'c_002' | 'c002')
            CHALLENGE_NAME="Vehicle Routing"
            ;;
        'c003' | 'c_003' | 'c003')
            CHALLENGE_NAME="Knapsack"
            ;;
        'c004' | 'c_004' | 'c004')
            CHALLENGE_NAME="Vector Search"
            ;;
        *)
            CHALLENGE_NAME="Unknown Challenge"
            ;;
    esac

    printf "ID: %-38s #Solutions: %-5s Challenge: %-20s Settings: %-50s \n" "$ID" "$NUM_SOLUTIONS" "$CHALLENGE_NAME" "$SETTINGS"
    SOLUTIONS_COUNT["$CHALLENGE_ID"]=$(( ${SOLUTIONS_COUNT["$CHALLENGE_ID"]:-0} + NUM_SOLUTIONS ))
done

echo "Total solutions by Challenge:"
for CHALLENGE_ID in "${!SOLUTIONS_COUNT[@]}"; do
    case $CHALLENGE_ID in
        'c001' | 'c_001' | 'c_001')
            CHALLENGE_NAME="Satisfiability"
            ;;
        'c002' | 'c_002' | 'c002')
            CHALLENGE_NAME="Vehicle Routing"
            ;;
        'c003' | 'c_003' | 'c003')
            CHALLENGE_NAME="Knapsack"
            ;;
        'c004' | 'c_004' | 'c004')
            CHALLENGE_NAME="Vector Search"
            ;;
        *)
            CHALLENGE_NAME="Unknown Challenge"
            ;;
    esac
    echo "Challenge: $CHALLENGE_NAME, Total Solutions: ${SOLUTIONS_COUNT[$CHALLENGE_ID]}"
done
