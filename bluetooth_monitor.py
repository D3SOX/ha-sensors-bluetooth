#!/usr/bin/env python3

import subprocess
import requests
import json
import time
import os
import logging
import dotenv
import sys
from datetime import datetime


ENV_PATH = os.path.expanduser('~/.local/share/ha-sensors-bluetooth/.env')
if os.path.exists(ENV_PATH):
    dotenv.load_dotenv(ENV_PATH)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('bluetooth_monitor')


WEBHOOK_URL = os.getenv('WEBHOOK_URL')
if not WEBHOOK_URL:
    logger.error("WEBHOOK_URL not set in environment. Please configure it in the .env file.")
    sys.exit(1)

CHECK_INTERVAL = int(os.getenv('CHECK_INTERVAL', "60"))

def get_bluetooth_connections():
    """Get connected Bluetooth devices using bluetoothctl"""
    try:
        # Get list of paired devices
        paired_cmd = ["bluetoothctl", "devices", "Paired"]
        paired_output = subprocess.check_output(paired_cmd).decode('utf-8').strip()
        paired_devices = {}
        
        for line in paired_output.split('\n'):
            if line.strip():
                parts = line.split(' ', 2)
                if len(parts) >= 3:
                    mac = parts[1]
                    name = parts[2]
                    paired_devices[mac] = name

        # Check which devices are connected
        connected_devices = []
        
        # For each paired device, check if it's connected
        for mac, name in paired_devices.items():
            info_cmd = ["bluetoothctl", "info", mac]
            info_output = subprocess.check_output(info_cmd).decode('utf-8').strip()
            
            if 'Connected: yes' in info_output:
                device_info = {
                    'mac': mac,
                    'name': name
                }
                
                # Extract battery info if available
                for line in info_output.split('\n'):
                    if 'Battery Percentage:' in line:
                        try:
                            battery_line = line.split('Battery Percentage:')[1].strip()
                            # Extract percentage from formats like "0x46 (70)"
                            if '(' in battery_line and ')' in battery_line:
                                battery = battery_line.split('(')[1].split(')')[0]
                                device_info['battery'] = battery
                        except Exception:
                            pass
                
                connected_devices.append(device_info)
            
        return connected_devices
    except Exception as e:
        logger.error(f"Error getting Bluetooth connections: {e}")
        return []

def send_to_homeassistant(devices):
    """Send Bluetooth connection info to Home Assistant"""
    try:
        connected = len(devices) > 0
        
        data = {
            "bluetooth_connected": connected,
            "devices": devices,
            "timestamp": datetime.now().isoformat()
        }
        
        response = requests.post(WEBHOOK_URL, json=data, timeout=10)
        if response.status_code == 200:
            logger.info(f"Successfully sent data to Home Assistant: {json.dumps(data)}")
            return True
        else:
            logger.error(f"Failed to send data to Home Assistant: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        logger.error(f"Error sending data to Home Assistant: {e}")
        return False

def main():
    """Main function to monitor Bluetooth and send to Home Assistant"""
    logger.info("Bluetooth monitor starting up")
    logger.info(f"Using webhook URL: {WEBHOOK_URL}")
    
    while True:
        try:
            connected_devices = get_bluetooth_connections()
            if connected_devices:
                logger.info(f"Found connected devices: {json.dumps(connected_devices)}")
            send_to_homeassistant(connected_devices)
        except Exception as e:
            logger.error(f"Error in main loop: {e}")
        
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main() 