#!/bin/bash

# Node Exporter Uninstallation Script for Ubuntu/Debian
# Author: rafiryd
# Date: 16-05-2024

# Variables
NODE_EXPORTER_VERSION="1.9.1" # Update this to match the version you installed, if necessary
NODE_EXPORTER_USER="node_exporter"
SERVICE_NAME="node_exporter"

echo "Step 1: Stopping and Disabling the Node Exporter service..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to stop or disable the Node Exporter service."
    exit 1
fi

echo "Step 2: Removing the systemd service file..."
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "Error: Failed to remove the systemd service file or reload daemon."
    exit 1
fi

echo "Step 3: Removing the Node Exporter binary..."
sudo rm -f /usr/local/bin/node_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to remove the Node Exporter binary."
    exit 1
fi

echo "Step 4: Removing the Node Exporter user..."
sudo userdel -r $NODE_EXPORTER_USER
if [ $? -ne 0 ] && [ $? -ne 6 ]; then
    echo "Error: Failed to remove the Node Exporter user."
    exit 1
fi

echo "Step 5: Cleaning up any remaining files..."
sudo rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*
if [ $? -ne 0 ] && [ $? -ne 1 ]; then
    echo "Error: Failed to clean up files."
    exit 1
fi

echo "Node Exporter uninstalled successfully!"
