#!/bin/bash

# Node Exporter Installation Script for Ubuntu/Debian
# Author: rafiryd
# Date: 24-11-2024

# Variables
NODE_EXPORTER_VERSION="1.9.1" # Update this to the latest version
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"

echo "Step 1: Downloading Node Exporter version $NODE_EXPORTER_VERSION..."
curl -LO $DOWNLOAD_URL
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Node Exporter."
    exit 1
fi

echo "Step 2: Extracting Node Exporter..."
tar -xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Node Exporter."
    exit 1
fi

echo "Step 3: Moving Node Exporter binary to /usr/local/bin..."
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error: Failed to move Node Exporter binary."
    exit 1
fi

echo "Step 4: Cleaning up temporary files..."
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*
if [ $? -ne 0 ]; then
    echo "Error: Failed to clean up files."
    exit 1
fi

echo "Step 5: Creating a dedicated user for Node Exporter..."
sudo useradd -rs /bin/false node_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to create node_exporter user."
    exit 1
fi

echo "Step 6: Creating systemd service file for Node Exporter..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9200

[Install]
WantedBy=multi-user.target
EOF
if [ $? -ne 0 ]; then
    echo "Error: Failed to create systemd service file."
    exit 1
fi

echo "Step 7: Reloading systemd and starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to start Node Exporter service."
    exit 1
fi

echo "Node Exporter installed and running successfully!"
echo "Verify at: http://<your-server-ip>:9100/metrics"

