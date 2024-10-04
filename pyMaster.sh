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
    git clone -b benchmarker_v2.0 https://github.com/tig-foundation/tig-monorepo.git
    cd tig-monorepo
    git config --global user.email "kyranmend@gmail.com"
    git config --global user.name "KyranMendoza1"
    git pull --no-edit --no-rebase https://github.com/tig-foundation/tig-monorepo.git vehicle_routing/cw_heuristic
    git pull --no-edit --no-rebase https://github.com/tig-foundation/tig-monorepo.git vector_search/invector
    git pull --no-edit --no-rebase https://github.com/tig-foundation/tig-monorepo.git knapsack/knapheudp
    git pull --no-edit --no-rebase https://github.com/tig-foundation/tig-monorepo.git satisfiability/sat_global

    #build tig-worker
    cargo build -p tig-worker --release

    #run Master
    cd tig-benchmarker
    pip3 install -r requirements.txt
    wget -O /root/tig-monorepo/tig-benchmarker/master/config.py https://raw.githubusercontent.com/KyranMendoza1/tig/main/config.py
    python3 main.py
'
