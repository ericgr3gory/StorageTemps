#!/bin/bash

# Check if the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

date

# Get a list of all hard drives
devices=$(lsblk -o NAME,TYPE,MOUNTPOINT | awk '$2=="disk" {print "/dev/"$1}')

# Loop through each hard drive
for device in $devices; do
    # Get the drive label
    label=$(lsblk -o LABEL "$device" | tail -n 1)

    # Get the mount point
    mount_point=$(lsblk -o MOUNTPOINT "$device" | tail -n 1)

    # Run smartctl command and extract current temperature
    temperature=$(sudo smartctl -x "$device" | awk '/Current (Drive )?(T|t)emperature:?/ {match($0, /[2-9][0-9]/); if (RSTART) {print substr($0, RSTART, RLENGTH); exit}}')

    # Check if temperature value is empty or contains invalid characters
    if [ -z "$temperature" ] || [ "$temperature" = "Unknown" ]; then
        temperature="NA"
    fi

    # Check if drive is mounted
    if [ -z "$mount_point" ]; then
        mounted="No"
    else
        mounted="Yes"
    fi

    # Print the device, label, temperature, and mounted status
    echo "${device} (${label}): ${temperature} C (Mounted: ${mounted})"
done
