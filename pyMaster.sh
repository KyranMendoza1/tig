#!/bin/bash
# Update the package list and install necessary packages
apt update
apt install -y tmux build-essential pkg-config libssl-dev git curl

# Start a new tmux session named 'tig-session' and run the commands inside it
tmux new-session -d -s tig-session bash -c '
    # Install Rust
    curl --proto =https --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    export PATH="$HOME/.cargo/bin:$PATH"

    # Clone and set up the repository
    git clone https://github.com/tig-foundation/tig-monorepo.git
    cd tig-monorepo
    git config --global user.email "kyranmend@gmail.com"
    git config --global user.name "KyranMendoza1"
    git pull origin vehicle_routing/cw_heuristic --no-edit --no-rebase
    git pull origin vector_search/invector --no-edit --no-rebase
    git pull origin knapsack/knapheudp --no-edit --no-rebase
    git pull origin satisfiability/sat_global --no-edit --no-rebase

    # Build tig-worker
    cargo build -p tig-worker --release

    # Run Master
    cd tig-benchmarker
    pip install -r requirements.txt
    wget -O ~/TIG/tig-monorepo/tig-benchmarker/config.json https://raw.githubusercontent.com/KyranMendoza1/tig/main/config.json

    python3 master.py 0x5de35f527176887b1b42a2703ba4d64e62a48de4 3de214b978b22a7b9c0957ccfc3a95a1 config.json
'
