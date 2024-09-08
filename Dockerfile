# Use the official Ubuntu base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install any required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    nano \
    git \
    build-essential \
    jq \

    && apt-get clean

# Copy your custom script into the container and make it executable
RUN wget https://raw.githubusercontent.com/KyranMendoza1/tig/main/startupscript.sh \
    && chmod +x startupscript.sh

# Set up the default command to run the script and then start a bash shell
CMD ["sh", "-c", "./startupscript.sh && exec bash"]
