#!/bin/bash
# Update the package list and install necessary packages
apt update
apt install -y tmux build-essential pkg-config libssl-dev git curl htop

# Start a new tmux session named 'tig-session' and run the commands inside it
tmux new-session -d -s tig-session bash -c '
    # Install Rust
    curl --proto =https --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    export PATH="$HOME/.cargo/bin:$PATH"

    #!/bin/bash

if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing..."
    sudo apt-get install figlet -y
fi

BLUE=$(echo -e "\033[0;34m")
RED_UNDERLINED=$(echo -e "\033[4;31m")
GREEN=$(echo -e "\033[0;32m")
BOLD=$(echo -e "\033[1m")
NC=$(echo -e "\033[0m")

cols=$(tput cols)
rows=$(tput lines)

right_text="Mining Pool"
version_text="v1.0"
right_text_length=${#right_text}
version_text_length=${#version_text}

left_text="Discord"
website_text="Website"
left_text_length=${#left_text}
website_text_length=${#website_text}

output=$(figlet -f slant "THE INNOVATION FORGE")

lines=()
while IFS= read -r line; do
    lines+=("$line")
done <<< "$output"

apt install -y bc

figlet_height=${#lines[@]}
vertical_padding=$(( (rows - figlet_height) / 2 ))

benchmarking_text_position=$(( rows / 2 ))
discord_text_position=$(( rows / 2 ))

clear

for ((i = 0; i < vertical_padding; i++)); do
    echo ""
done

for line in "${lines[@]}"; do
    line_length=${#line}
    padding=$(( (cols - line_length) / 2 ))
    printf "%*s%s%s%s\n" $padding "" "$BLUE" "$line" "$NC"
done

right_padding=3

tput cup $benchmarking_text_position $((cols - right_text_length - right_padding))
printf "%s\n" "$right_text"

tput cup $((benchmarking_text_position + 1)) $((cols - version_text_length - right_padding - (right_text_length - version_text_length) / 2))
printf "%s\n" "$version_text"

left_padding=3

tput cup $discord_text_position $((left_padding))
printf "%s%s%s\n" "$RED_UNDERLINED" "$left_text" "$NC"

tput cup $((discord_text_position + 1)) $((left_padding + (left_text_length - website_text_length) / 2))
printf "%s%s%s\n" "$RED_UNDERLINED" "$website_text" "$NC"

display_menu() {
    menu_start_position=$((vertical_padding + figlet_height + 2))

    options=(
        "Start a new installation"
        "Update your benchmarker"
        "View your ID (address/name)"
        "Cancel"
    )

    title="Please select an option:"
    title_length=${#title}
    tput cup $menu_start_position $(( (cols - title_length) / 2 ))
    printf "%s%s%s%s\n" "$GREEN" "$BOLD" "$title" "$NC"

    for i in "${!options[@]}"; do
        option="${options[$i]}"
        option_text="$((i+1)). $option"
        option_length=${#option_text}
        tput cup $((menu_start_position + i + 1)) $(( (cols - option_length) / 2 ))
        printf "%s%s%s\n" "$GREEN" "$option_text" "$NC"
    done

    tput cup $((menu_start_position + ${#options[@]} + 1)) $(( (cols - 23) / 2 ))
    printf "%s%sEnter your choice (1-4):%s " "$GREEN" "$BOLD" "$NC"
    read choice
}

view_id() {
    if [ -f "/root/tif-miningpool/address_name" ]; then
        cat "/root/tif-miningpool/address_name"
    else
        echo "The address_name file does not exist. It seems The Innovation Forge is not installed yet."
    fi
}

update_benchmarker() {
    if [ -d "/root/tif-miningpool" ]; then
        echo "Stopping the current benchmarker service..."
        /etc/init.d/tif-miningpool stop

        cd /root/tif-miningpool/tig-monorepo/tig-benchmarker || {
            echo "Unable to find the benchmarker directory. The Innovation Forge might not be installed correctly."
            return
        }
        echo "Updating the benchmarker..."
        git fetch --all
        git reset --hard origin/main

        echo "Restarting the benchmarker service..."
        /etc/init.d/tif-miningpool start

        echo "Update complete. Displaying the service log..."
        tail -f /var/log/tif-miningpool.log
    else
        echo "The Innovation Forge is not installed."
    fi
}

while true; do
    display_menu
    case $choice in
        1)
            echo "Starting new installation..."
            break
            ;;
        2)
            update_benchmarker
            ;;
        3)
            view_id
            ;;
        4)
            echo "Cancelling and exiting the script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

contains_special_chars() {
    if [[ $1 =~ [^a-zA-Z0-9] ]]; then
        return 0 # true if there are special characters
    else
        return 1 # false otherwise
    fi
}

while true; do
    read -p "Please enter your address where you want to receive your rewards (wallet): " address
    if [ -z "$address" ]; then
        echo "Error: The address cannot be empty. Please try again."
    elif contains_special_chars "$address"; then
        echo "Error: The address must not contain special characters. Please try again."
    else
        address=$(echo "$address" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
        break
    fi
done

while true; do
    read -p "Please enter a unique name for your server (max 15 characters, no special characters): " server_name
    if [ -z "$server_name" ]; then
        echo "Error: The server name cannot be empty. Please try again."
    elif contains_special_chars "$server_name"; then
        echo "Error: The server name must not contain special characters. Please try again."
    elif [ ${#server_name} -gt 15 ]; then
        echo "Error: The server name must not exceed 15 characters. Please try again."
    else
        break
    fi
done

echo "Server name accepted: $server_name"
echo "Make sure this name is unique to avoid conflicts with other benchmarkers."

concat="${address}_${server_name}"
echo "The concatenation of the address and name is: $concat"

if [ -d "/root/tif-miningpool" ]; then
    echo "The tif-miningpool directory already exists. Deleting it..."
    rm -rf /root/tif-miningpool
fi

echo "Creating the tif-miningpool directory..."
mkdir -p /root/tif-miningpool
cd /root/tif-miningpool || exit

echo "Generating the information file..."
cat << EOF > address_name
address = $address
name = $server_name
EOF
echo "File address_name created in /root/tif-miningpool"

echo "Cloning the tig-monorepo repository..."
git clone https://github.com/tig-foundation/tig-monorepo.git

echo "Updating packages..."
apt-get update -y

install_python() {
    version=$1
    echo "Attempting to install Python $version..."
    if apt-get install -y python$version python$version-venv; then
        echo "Python $version installed successfully."
        return 0
    else
        echo "Failed to install Python $version."
        return 1
    fi
}

python_versions=("3.11" "3.10" "3.9" "3.8")
for version in "${python_versions[@]}"; do
    if install_python $version; then
        python_version=$version
        break
    fi
done

if [ -z "$python_version" ]; then
    echo "Unable to install a compatible Python version. Stopping the script."
    exit 1
fi

echo "Creating and activating the virtual environment with Python $python_version..."
python$python_version -m venv /root/tif-miningpool/myenv
source /root/tif-miningpool/myenv/bin/activate

echo "Installing Python dependencies..."
python$python_version -m pip install -r ./tig-monorepo/tig-benchmarker/requirements.txt
python$python_version -m pip install requests

echo "Installing Cargo and rustup..."
apt-get install -y cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "Compiling tig-worker..."
cd tig-monorepo || exit
cargo build -p tig-worker --release

echo "chmod on tig-worker files..."
chmod +x ./target/release/tig-worker

nproc=$(nproc)
workers=$nproc

echo "Creating SysVinit service for TIG Worker..."
cat << EOF > /etc/init.d/tif-miningpool
#!/bin/sh
### BEGIN INIT INFO
# Provides:          tif-miningpool
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start TIG Worker at boot time
# Description:       Enable service provided by TIG Worker.
### END INIT INFO

case "\$1" in
  start)
    echo "Starting TIG Worker..."
    /root/tif-miningpool/myenv/bin/python /root/tif-miningpool/tig-monorepo/tig-benchmarker/slave.py --workers $workers --name "${concat}_${nproc}" theinnovationforge.tf /root/tif-miningpool/tig-monorepo/target/release/tig-worker &
    echo \$! > /var/run/tif-miningpool.pid
    ;;
  stop)
    echo "Stopping TIG Worker..."
    kill $(cat /var/run/tif-miningpool.pid)
    rm /var/run/tif-miningpool.pid
    ;;
  restart)
    \$0 stop
    \$0 start
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart}"
    exit 1
esac

exit 0
EOF

chmod +x /etc/init.d/tif-miningpool
update-rc.d tif-miningpool defaults
/etc/init.d/tif-miningpool start

echo "The TIG Worker service has been created, enabled, and started."
echo "You can check its status with: tail -f /var/log/tif-miningpool.log"

echo -e "\033[34m
# Information for benchmarkers:
# Restart your benchmarker: /etc/init.d/tif-miningpool restart
# Stop your benchmarker: /etc/init.d/tif-miningpool stop
# View your benchmarker log: tail -f /var/log/tif-miningpool.log
\033[0m"

tput cup $((rows)) 0
    '
