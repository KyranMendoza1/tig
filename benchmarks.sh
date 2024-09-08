#!/bin/bash
set -e
apt-get install jq -y

PLAYER_ID=0x5de35f527176887b1b42a2703ba4d64e62a48de4

while true; do
    BLOCK_ID=$(curl -s https://mainnet-api.tig.foundation/get-block | jq -r '.block.id')
    RESP=$(curl -s "https://mainnet-api.tig.foundation/get-benchmarks?block_id=$BLOCK_ID&player_id=$PLAYER_ID")

    BENCHMARKS=$(echo $RESP | jq -c '[.benchmarks[]] | sort_by(.settings.challenge_id, -.details.num_solutions)')

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

        # Display new challenge found
        echo "New challenge found: $CHALLENGE_NAME (ID: $ID) - Solutions: $NUM_SOLUTIONS"
    done

    # Wait before checking again
    sleep 5
done
