#!/bin/bash
device_count=$(bluetoothctl devices | grep "Device" | wc -l)
echo $device_count
