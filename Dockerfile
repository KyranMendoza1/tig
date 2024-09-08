# Use the official Ubuntu base image
FROM ubuntu:latest
# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
# Update the package list and install any required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    && apt-get clean
# Copy your custom script into the container and make it executable
RUN wget https://raw.githubusercontent.com/KyranMendoza1/tig/main/startupscript.sh \
    && chmod +x startupscript.sh
# Set up the default command to run the script and then start an infinite loop to keep the container running
CMD ["sh", "-c", "./startupscript.sh && while :; do sleep 2073600; done"]
