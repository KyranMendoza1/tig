# Use the official Ubuntu base image
FROM ubuntu:latest

# Set environment variables (if needed)
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install any required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    git \
    build-essential \
    # Add any other packages you need
    && apt-get clean

# Copy your custom files into the container
# COPY ./my-custom-file /path/in/container/

# Example of running a custom script
# RUN /path/to/your/script.sh

# Set up a default command (if you want the container to run something by default)
CMD ["bash"]
