#!/bin/bash
# This script installs Prometheus on Ubuntu/Debian Linux
# Prometheus LTS version: 3.13.2
# Prometheus latest release: 3.14.0

set -e

# Define Prometheus version
PROMETHEUS_VERSION="3.13.2"

echo "=========================================="
echo "Installing Prometheus ${PROMETHEUS_VERSION}"
echo "=========================================="

# Update system and install necessary packages
echo "Updating system and installing dependencies..."

sudo apt-get update -y
sudo apt-get install -y wget tar

# Create Prometheus user if it does not already exist
echo "Creating Prometheus user..."

if ! id prometheus &>/dev/null; then
    sudo useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        prometheus
else
    echo "Prometheus user already exists."
fi

# Create Prometheus configuration directory
echo "Creating Prometheus directories..."

sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus ${PROMETHEUS_VERSION}..."

cd /tmp

wget -q --show-progress \
    https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Extract Prometheus
echo "Extracting Prometheus..."

tar -xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Copy Prometheus configuration and console files
echo "Installing Prometheus configuration files..."

sudo cp -r \
    prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles \
    /etc/prometheus/

sudo cp -r \
    prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries \
    /etc/prometheus/

sudo cp \
    prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml \
    /etc/prometheus/

# Install Prometheus binaries
echo "Installing Prometheus binaries..."

sudo cp \
    prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus \
    /usr/local/bin/

sudo cp \
    prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool \
    /usr/local/bin/

# Set executable permissions
sudo chmod +x /usr/local/bin/prometheus
sudo chmod +x /usr/local/bin/promtool

# Set ownership
echo "Setting permissions..."

sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Validate Prometheus configuration
echo "Validating Prometheus configuration..."

sudo -u prometheus \
    /usr/local/bin/promtool check config /etc/prometheus/prometheus.yml

# Create Prometheus systemd service
echo "Creating Prometheus systemd service..."

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring System
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple

ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
echo "Reloading systemd..."

sudo systemctl daemon-reload

# Enable and start Prometheus
echo "Starting Prometheus..."

sudo systemctl enable --now prometheus

# Wait a few seconds for Prometheus to start
sleep 3

# Check Prometheus service status
echo ""
echo "=========================================="
echo "Prometheus installation completed!"
echo "=========================================="

if sudo systemctl is-active --quiet prometheus; then
    echo "Prometheus service: RUNNING"
else
    echo "Prometheus service: FAILED"
    echo ""
    sudo systemctl status prometheus --no-pager
    exit 1
fi

echo ""
echo "Prometheus version:"
/usr/local/bin/prometheus --version

echo ""
echo "Prometheus service status:"
sudo systemctl status prometheus --no-pager

echo ""
echo "Prometheus is available at:"
echo "http://YOUR-SERVER-IP:9090"

# Remove downloaded files
echo ""
echo "Cleaning up downloaded files..."

rm -rf \
    /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64 \
    /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

echo ""
echo "Installation finished successfully!"
