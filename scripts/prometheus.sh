#!/bin/bash
# This script installs Prometheus 3.13.2 on Ubuntu/Debian Linux

set -e

# Define Prometheus version
PROMETHEUS_VERSION="3.13.2"
PROMETHEUS_USER="prometheus"
PROMETHEUS_DIR="/etc/prometheus"
PROMETHEUS_DATA_DIR="/var/lib/prometheus"

echo "=========================================="
echo "Installing Prometheus ${PROMETHEUS_VERSION}"
echo "=========================================="

# Update system and install dependencies
echo "Updating system and installing dependencies..."

sudo apt-get update -y
sudo apt-get install -y wget tar

# Create Prometheus user if it does not already exist
echo "Creating Prometheus user..."

if ! id "${PROMETHEUS_USER}" >/dev/null 2>&1; then
    sudo useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        "${PROMETHEUS_USER}"
else
    echo "Prometheus user already exists."
fi

# Create Prometheus directories
echo "Creating Prometheus directories..."

sudo mkdir -p "${PROMETHEUS_DIR}"
sudo mkdir -p "${PROMETHEUS_DATA_DIR}"

# Download Prometheus
echo "Downloading Prometheus ${PROMETHEUS_VERSION}..."

cd /tmp

rm -f "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
rm -rf "prometheus-${PROMETHEUS_VERSION}.linux-amd64"

wget -q --show-progress \
    "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

# Extract Prometheus
echo "Extracting Prometheus..."

tar -xzf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

# Install Prometheus binaries
echo "Installing Prometheus binaries..."

sudo cp \
    "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus" \
    /usr/local/bin/prometheus

sudo cp \
    "prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool" \
    /usr/local/bin/promtool

# Make binaries executable
sudo chmod +x /usr/local/bin/prometheus
sudo chmod +x /usr/local/bin/promtool

# Install Prometheus configuration
echo "Installing Prometheus configuration..."

sudo cp \
    "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml" \
    "${PROMETHEUS_DIR}/prometheus.yml"

# Set ownership
echo "Setting permissions..."

sudo chown -R "${PROMETHEUS_USER}:${PROMETHEUS_USER}" \
    "${PROMETHEUS_DIR}"

sudo chown -R "${PROMETHEUS_USER}:${PROMETHEUS_USER}" \
    "${PROMETHEUS_DATA_DIR}"

sudo chown "${PROMETHEUS_USER}:${PROMETHEUS_USER}" \
    /usr/local/bin/prometheus

sudo chown "${PROMETHEUS_USER}:${PROMETHEUS_USER}" \
    /usr/local/bin/promtool

# Validate Prometheus configuration
echo "Validating Prometheus configuration..."

sudo -u "${PROMETHEUS_USER}" \
    /usr/local/bin/promtool check config \
    "${PROMETHEUS_DIR}/prometheus.yml"

# Create Prometheus systemd service
echo "Creating Prometheus systemd service..."

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring System
Wants=network-online.target
After=network-online.target

[Service]
User=${PROMETHEUS_USER}
Group=${PROMETHEUS_USER}
Type=simple

ExecStart=/usr/local/bin/prometheus \\
  --config.file=${PROMETHEUS_DIR}/prometheus.yml \\
  --storage.tsdb.path=${PROMETHEUS_DATA_DIR}

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

# Wait for service to start
sleep 3

# Check Prometheus service
echo ""
echo "=========================================="
echo "Checking Prometheus service"
echo "=========================================="

if sudo systemctl is-active --quiet prometheus; then
    echo "Prometheus service: RUNNING"
else
    echo "Prometheus service: FAILED"
    sudo systemctl status prometheus --no-pager
    exit 1
fi

# Display installed version
echo ""
echo "Prometheus version:"
/usr/local/bin/prometheus --version

# Display service status
echo ""
echo "Prometheus service status:"
sudo systemctl status prometheus --no-pager

# Cleanup
echo ""
echo "Cleaning up downloaded files..."

rm -rf \
    "/tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64" \
    "/tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

echo ""
echo "=========================================="
echo "Prometheus installation completed!"
echo "=========================================="
echo ""
echo "Prometheus URL:"
echo "http://YOUR-SERVER-IP:9090"
echo ""
