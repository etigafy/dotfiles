#!/bin/bash

percentage="0"
power=""
bluetoothctl info > /dev/null 2>&1
ret=$?
if [ $ret -eq 0 ]; then
	percentage=$(bluetoothctl info | grep Battery| sed 's/.*(\([0-9]*\)).*/\1/')
	power=$(bluetoothctl show | grep PowerState | cut -d ':' -f2 | xargs)
	if [ "$power" == "off" ]; then
		percentage="0"
	fi
fi

#device_count=$(bluetoothctl info | grep "Battery" | wc -l)
echo "{\"percentage\": $percentage, \"class\": \"custom-bluetooth\"}"
