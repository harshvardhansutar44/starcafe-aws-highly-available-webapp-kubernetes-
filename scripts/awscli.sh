#!/bin/bash
# Script to install AWS CLI on an instance

# Update package list
sudo apt-get update -y

# Install required dependencies
sudo apt-get install -y curl unzip

# Download the AWS CLI installer for x86_64
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the AWS CLI installer
unzip awscliv2.zip

# Run the AWS CLI installation script
sudo ./aws/install

# Verify installation
aws --version
