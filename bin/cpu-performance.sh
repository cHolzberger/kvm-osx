#!/bin/bash

CPUCOUNT=$(ls /sys/bus/cpu/devices/ | wc -l)

echo "Found $CPUCOUNT cpus"
echo "Setting performance governor"

ls /sys/bus/cpu/devices | while read cpu; do

echo "Setting: " $cpu
echo -n "performance" > /sys/bus/cpu/devices/$cpu/cpufreq/scaling_governor
done
