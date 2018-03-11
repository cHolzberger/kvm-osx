#!/bin/bash

# this is strange, helps cpu stalls
sysctl -w vm.min_free_kbytes=64072
### disK PERFORMANcE

echo "Numa"

if [ -e /proc/sys/kernel/numa_balancing ]; then
	echo 0 > /proc/sys/kernel/numa_balancing || true
fi

CPUCOUNT=$(ls /sys/bus/cpu/devices/ | wc -l)

	echo "enable ksm for host"
echo -n 0 >  /sys/kernel/mm/ksm/run || true
echo -n 0 > /sys/kernel/mm/ksm/merge_across_nodes || true

if [ -e /sys/devices/system/cpu/intel_pstate/min_perf_pct ]; then
	echo "Setting minimum performance"
	echo -n 100 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
fi
echo "Found $CPUCOUNT cpus"
echo "Setting performance governor"

ls /sys/bus/cpu/devices | while read cpu; do
	echo -n "performance" > /sys/bus/cpu/devices/$cpu/cpufreq/scaling_governor
	echo "Setting: $cpu Gov: $(cat /sys/bus/cpu/devices/$cpu/cpufreq/scaling_governor)"
done
