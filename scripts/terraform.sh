#!/bin/bash
# Script to install Terraform on an instance

# Update package list and install dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# Add HashiCorp GPG key
sudo mkdir -p -m 755 /etc/apt/keyrings

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /etc/apt/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the key fingerprint
gpg --no-default-keyring \
--keyring /etc/apt/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# Add HashiCorp repository to sources list
echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package lists
sudo apt update

# Install Terraform
sudo apt-get install terraform -y

# Verify installation
terraform -v
