# Home Assistant Linux Bluetooth Sensor

A monitoring system that reports connected Bluetooth devices from your Linux system to Home Assistant via webhooks.

## Features

- Monitors Bluetooth connections on Linux systems
- Reports connected devices to Home Assistant
- Detects device battery levels when available
- Creates a binary sensor for connection status
- Runs as a systemd user service

## Prerequisites

- Linux system with Bluetooth capability
- Home Assistant instance accessible on your network
- Python 3 with `requests` and `python-dotenv` packages
- `bluez` / `bluez-utils` package installed (provides `bluetoothctl`)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/D3SOX/ha-sensors-bluetooth.git
   cd ha-sensors-bluetooth
   ```

2. Add the provided Home Assistant configuration:
   - Merge the contents of [`config/configuration.yaml`](./config/configuration.yaml) with your configuration.yaml and Quick reload Home Assistant via the Developer Tools.
   - Create a automation and paste the yaml from [`config/bluetooth_webhook_automation.yaml`](./config/bluetooth_webhook_automation.yaml). 
   - You can remove and add the Webhook trigger to get a new webhook id.

3. Run the installation script:
   ```bash
   ./scripts/install_bluetooth_monitor.sh
   ```

4. Follow the prompts to enter your Home Assistant webhook URL.

## How It Works

The system uses `bluetoothctl` to query connected Bluetooth devices on your Linux system. Every minute (configurable), it sends this information to Home Assistant via a webhook. Home Assistant then updates the binary sensor based on this data.

## Configuration

Configuration is stored in `~/.local/share/ha-sensors-bluetooth/.env`. You can modify:

- `WEBHOOK_URL`: The webhook URL for Home Assistant
- `CHECK_INTERVAL`: How often to check for connected devices (in seconds)

## Usage Examples

### Battery Level Monitoring

The repository includes a sample automation [`examples/bluetooth_battery_notification.yaml`](./examples/bluetooth_battery_notification.yaml) to monitor battery levels of connected Bluetooth devices. It sends notifications when battery levels of a device fall below a configurable threshold (default is 30%)

### Smart Playback of Notifications

You can use this sensor with [Browser Mod](https://github.com/thomasloven/hass-browser_mod) to make your notifications play in your browser when your PC is on and a bluetooth device is connected.

### Dashboard

You can use this sensor to create a dashboard of all connected devices with battery status. The repository includes a sample dashboard card [`examples/dashboard-card.yaml`](./examples/dashboard-card.yaml) to display the connected devices. It shows device name, battery percentage, and connection status.

![image](https://github.com/user-attachments/assets/5c4d8201-37f5-4c5e-aaf3-262d6c12fc21)

## Troubleshooting

### Checking Service Status
```bash
systemctl --user status bluetooth-monitor.service
```

### Viewing Logs
```bash
journalctl --user -u bluetooth-monitor.service -f
```

## Uninstallation

```bash
./scripts/uninstall_bluetooth_monitor.sh
```

## License

This project is licensed under the MIT License.
