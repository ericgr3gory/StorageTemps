#!/bin/bash


# Check if the FANSPEED environment variable is set
if [ -n "$FANSPEED" ]; then
    fanspeed=$FANSPEED
elif [ $# -ge 1 ]; then
    # Use the first command line argument as fanspeed if provided
    fanspeed=$1
else
    # Default fan speed if neither environmental variable nor command line argument is provided
    fanspeed=50
fi

# Check if fanspeed is within the range of 10 to 100
if ! [[ "$fanspeed" =~ ^[0-9]+$ ]] || ((fanspeed < 10 || fanspeed > 100)); then
    echo "Error: Fanspeed must be an integer between 10 and 100"
    exit 1
fi

for i in {1..30};do
    echo $i
    
    for u in {1..3};do
        echo $u
        usb_device="/dev/ttyUSB$u"
        stty -F $usb_device speed 38400 cs8 -ixon raw
        echo -ne "set_temp 0 0\n\r" > $usb_device
        echo -ne "set_temp 1 0\n\r" > $usb_device
        for f in {0..4};do
            echo -ne "set_speed $fanspeed\n\r" > $usb_device
        done
    done

sleep 2
done
exit 0
