#!/bin/bash
# Jenkins Installation on Ubuntu

set -e

sudo apt update

sudo apt install -y fontconfig openjdk-17-jre wget

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update

sudo apt install -y jenkins

sudo systemctl enable --now jenkins

echo "Jenkins installation completed."

echo "Check status:"
echo "sudo systemctl status jenkins"

echo "Initial admin password:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
