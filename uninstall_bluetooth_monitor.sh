#!/bin/bash

# Bluetooth Monitor Uninstallation Script
set -e

echo "Uninstalling Bluetooth Monitor for Home Assistant"
echo "================================================"

# Stop and disable the service
echo "Stopping and disabling service..."
systemctl --user stop bluetooth-monitor.service 2>/dev/null || true
systemctl --user disable bluetooth-monitor.service 2>/dev/null || true

# Remove service file
echo "Removing service file..."
rm -f "$HOME/.config/systemd/user/bluetooth-monitor.service"
systemctl --user daemon-reload

# Remove installation directory
INSTALL_DIR="$HOME/.local/share/ha-sensors-bluetooth"
echo "Removing installation directory: $INSTALL_DIR"
rm -rf "$INSTALL_DIR"

echo
echo "Uninstallation complete!"
echo
echo "The Bluetooth monitor service has been removed."
echo "Note: Any Home Assistant entities created by this service will remain until you remove them manually." 