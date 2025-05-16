#!/bin/bash

# Haproxy Exporter Uninstallation Script for Ubuntu/Debian
# Author: rafiryd
# Date: 16-05-2024  (Or whatever the current date is)

# Variables (It's good to keep the version for cleanup, though not strictly necessary for *all* steps)
HAPROXY_EXPORTER_VERSION="0.15.0" #  Modify if you need to clean up specific version files
HAPROXY_USER="haproxy_exporter"
SERVICE_NAME="haproxy_exporter"


echo "Step 1: Stopping and Disabling the HAProxy Exporter service..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME
if [ $? -ne 0 ]; then
    echo "Error: Failed to stop or disable the HAProxy Exporter service."
    exit 1
fi

echo "Step 2: Removing the systemd service file..."
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "Error: Failed to remove the systemd service file or reload daemon."
    exit 1
fi

echo "Step 3: Removing the HAProxy Exporter binary..."
sudo rm -f /usr/local/bin/haproxy_exporter
if [ $? -ne 0 ]; then
    echo "Error: Failed to remove the HAProxy Exporter binary."
    exit 1
fi

echo "Step 4: Removing the HAProxy Exporter user..."
sudo userdel -r $HAPROXY_USER  # The -r flag removes the user's home directory too (if it exists, which it shouldn't in this case)
if [ $? -ne 0 ] && [ $? -ne 1 ]; then # Userdel returns 0 if successful, 6 if user doesn't exist, other values on other errors
    echo "Error: Failed to remove the HAProxy Exporter user."
    exit 1
fi

echo "Step 5: Cleaning up any remaining files (version-specific)..."
sudo rm -rf  haproxy_exporter-$HAPROXY_EXPORTER_VERSION.linux-amd64* #  Be cautious with wildcards in rm -rf
if [ $? -ne 0 ] && [ $? -ne 1 ]; then # rm -rf  returns 0 if successful, 1 if it fails
    echo "Error: Failed to clean up files."
    exit 1
fi

echo "HAProxy Exporter uninstalled successfully!"