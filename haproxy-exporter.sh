#!/bin/bash

# Haproxy Exporter Installation Script for Ubuntu/Debian
# Author: rafiryd
# Date: 16-05-2025

# Variables
HAPROXY_EXPORTER_VERSION="0.15.0" # Update this to the latest version
DOWNLOAD_URL="https://github.com/prometheus/haproxy_exporter/releases/download/v$HAPROXY_EXPORTER_VERSION/haproxy_exporter-$HAPROXY_EXPORTER_VERSION.linux-amd64.tar.gz"

echo "Step 1: Downloading Haproxy Exporter version $HAPROXY_EXPORTER_VERSION..."
curl -LO $DOWNLOAD_URL
if [ $? -ne 0 ]; then
    echo "Error: Failed to download HAProxy Exporter."
    exit 1
fi

echo "Step 2: Extracting HAProxy Exporter..."
tar -xvf haproxy_exporter-$HAPROXY_EXPORTER_VERSION.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract HAProxy Exporter."
    exit 1
fi

echo "Step 3: Moving HAProxy Exporter binary to /usr/local/bin..."
sudo mv haproxy_exporter-$HAPROXY_EXPORTER_VERSION.linux-amd64/haproxy_exporter /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error: Failed to move HAProxy Exporter binary."
    exit 1
fi

echo "Step 4: Cleaning up temporary files..."
rm -rf haproxy_exporter-$HAPROXY_EXPORTER_VERSION.linux-amd64*
if [ $? -ne 0 ]; then
    echo "Error: Failed to clean up files."
    exit 1
fi

echo "Step 5: Creating a dedicated user for HAProxy Exporter..."
sudo useradd -rs /bin/false haproxy_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to create haproxy_exporter user."
    exit 1
fi

echo "Step 6: Creating systemd service file for HAProxy Exporter..."
sudo tee /etc/systemd/system/haproxy_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus HAProxy Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=haproxy_exporter
Group=haproxy_exporter
Type=simple
ExecStart=/usr/local/bin/haproxy_exporter  --haproxy.scrape-uri="http://admin:QW!@er34@10.100.1.91:9000/stats;csv" --web.listen-address=9200

[Install]
WantedBy=multi-user.target
EOF
if [ $? -ne 0 ]; then
    echo "Error: Failed to create systemd service file."
    exit 1
fi

echo "Step 7: Reloading systemd and starting HAProxy Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start haproxy_exporter
sudo systemctl enable haproxy_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to start HAProxy Exporter service."
    exit 1
fi

echo "HAProxy Exporter installed and running successfully!"
echo "Verify at: http://<your-server-ip>:9200/metrics"
