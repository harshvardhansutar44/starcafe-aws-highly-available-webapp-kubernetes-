#!/bin/bash
# Jenkins LTS Installation on Ubuntu
# Updated: August 2026

set -e

echo "========================================="
echo "Step 1: Update Ubuntu packages"
echo "========================================="

sudo apt update
sudo apt upgrade -y


echo "========================================="
echo "Step 2: Install Java 21 and dependencies"
echo "========================================="

sudo apt install -y fontconfig openjdk-21-jre wget

echo "Checking Java version:"
java -version


echo "========================================="
echo "Step 3: Add Jenkins repository signing key"
echo "========================================="

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key


echo "========================================="
echo "Step 4: Add Jenkins LTS repository"
echo "========================================="

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null


echo "========================================="
echo "Step 5: Update package repository"
echo "========================================="

sudo apt update


echo "========================================="
echo "Step 6: Install Jenkins"
echo "========================================="

sudo apt install -y jenkins


echo "========================================="
echo "Step 7: Enable and start Jenkins"
echo "========================================="

sudo systemctl enable --now jenkins


echo "========================================="
echo "Step 8: Check Jenkins service"
echo "========================================="

sudo systemctl status jenkins --no-pager


echo "========================================="
echo "Jenkins installation completed!"
echo "========================================="

echo
echo "Jenkins URL:"
echo "http://<SERVER-IP>:8080"

echo
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
