#!/bin/bash
# Script to install Grafana OSS on Ubuntu/Debian Linux

set -e

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https wget gnupg

# Create a directory for Grafana's GPG key
sudo mkdir -p /etc/apt/keyrings

# Add Grafana's GPG key
sudo wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key

# Set correct permissions for the GPG key
sudo chmod 644 /etc/apt/keyrings/grafana.asc

# Add Grafana's stable APT repository
echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | \
sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null

# Update package lists
sudo apt-get update

# Install the latest stable Grafana OSS release
sudo apt-get install -y grafana

# Enable Grafana to start automatically at boot
# and start the Grafana service now
sudo systemctl enable --now grafana-server

# Check Grafana service status
sudo systemctl status grafana-server --no-pager

echo ""
echo "=========================================="
echo "Grafana installation completed!"
echo "=========================================="
echo ""
echo "Grafana service status:"
sudo systemctl is-active grafana-server

echo ""
echo "Access Grafana at:"
echo "http://YOUR-SERVER-IP:3000"
echo ""
echo "Default username: admin"
echo "You will be prompted to change the default password on first login."
