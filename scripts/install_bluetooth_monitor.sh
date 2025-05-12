#!/bin/bash

# Bluetooth Monitor Installation Script
set -e

echo "Installing Bluetooth Monitor for Home Assistant"
echo "=============================================="

# Check dependencies
echo "Checking dependencies..."
if ! command -v bluetoothctl &> /dev/null; then
    echo "Error: bluetoothctl not found. Please install bluez package."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 not found. Please install python3."
    exit 1
fi

# Check Python dependencies
echo "Checking Python dependencies..."
if ! pip3 list | grep "requests"; then
    echo "Warning: Python package 'requests' is not installed. Please install it with your system's package manager or alternatively pip3 install --user requests"
fi

if ! pip3 list | grep "python-dotenv"; then
    echo "Warning: Python package 'python-dotenv' is not installed. Please install it with your system's package manager or alternatively pip3 install --user python-dotenv"
fi

# Create dedicated directory structure
INSTALL_DIR="$HOME/.local/share/ha-sensors-bluetooth"
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Copy Bluetooth monitor script to installation directory
echo "Installing Bluetooth monitor script..."
cp ../bluetooth_monitor.py "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/bluetooth_monitor.py"

# Prompt user for webhook URL
echo
echo "You need to provide a webhook URL for your Home Assistant instance."
echo "Example: http://192.168.1.100:8123/api/webhook/bluetooth_monitor"
read -p "Enter your Home Assistant webhook URL: " webhook_url
if [ -z "$webhook_url" ]; then
    echo "Error: Webhook URL cannot be empty."
    exit 1
fi

# Create .env file
echo "Creating environment configuration..."
cat > "$INSTALL_DIR/.env" << EOF
# Bluetooth Monitor Configuration
WEBHOOK_URL=${webhook_url}
CHECK_INTERVAL=30
EOF

echo "Environment file created at $INSTALL_DIR/.env"

# Install systemd user service
echo "Installing systemd user service..."
mkdir -p "$HOME/.config/systemd/user/"
cp ../bluetooth-monitor.service "$HOME/.config/systemd/user/"

# Enable and start the service
echo "Enabling and starting service..."
systemctl --user daemon-reload
systemctl --user enable bluetooth-monitor.service
systemctl --user start bluetooth-monitor.service

echo
echo "Installation complete!"
echo
echo "Next steps:"
echo "Make sure you have followed the instructions in the README.md file under Installation section."
echo
echo "The Bluetooth monitor service is now running. You can check its status with:"
echo "  systemctl --user status bluetooth-monitor.service"
echo
echo "To view logs, use:"
echo "  journalctl --user -u bluetooth-monitor.service -f"
echo
echo "Configuration file is at $INSTALL_DIR/.env"
echo "You can edit this file to change the webhook URL or check interval."
echo
echo "Bluetooth device data will be available as:"
echo "  - binary_sensor.pc_bluetooth_connection (on/off) with attributes:"
echo "    - device_count (number of devices connected)"
echo "    - timestamp (last updated timestamp)"
echo "    - devices (list of device with name, MAC address and battery level)"