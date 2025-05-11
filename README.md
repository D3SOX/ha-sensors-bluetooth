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
   - Merge the contents of [`configuration.yaml`](./configuration.yaml) with your configuration.yaml and Quick reload Home Assistant via the Developer Tools.
   - Create a automation and paste the yaml from [`bluetooth_webhook_automation.yaml.yaml`](./bluetooth_webhook_automation.yaml.yaml). 
   - You can remove and add the Webhook trigger to get a new webhook id.

3. Run the installation script:
   ```bash
   ./install_bluetooth_monitor.sh
   ```

4. Follow the prompts to enter your Home Assistant webhook URL.

## How It Works

The system uses `bluetoothctl` to query connected Bluetooth devices on your Linux system. Every minute (configurable), it sends this information to Home Assistant via a webhook. Home Assistant then updates the binary sensor based on this data.

## Configuration

Configuration is stored in `~/.local/share/ha-sensors-bluetooth/.env`. You can modify:

- `WEBHOOK_URL`: The webhook URL for Home Assistant
- `CHECK_INTERVAL`: How often to check for connected devices (in seconds)

## Troubleshooting

### Checking Service Status
```bash
systemctl --user status bluetooth-monitor.service
```

### Viewing Logs
```bash
journalctl --user -u bluetooth-monitor.service -f
```

## License

This project is licensed under the MIT License.
