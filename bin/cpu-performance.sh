#!/bin/bash
HOST_CORES_MASK=1
# this is strange, helps cpu stalls
 sysctl -w vm.min_free_kbytes=64072
### disK PERFORMANcE

echo "Numa"

if [ -e /proc/sys/kernel/numa_balancing ]; then
	echo 0 > /proc/sys/kernel/numa_balancing || true
fi

CPUCOUNT=$(ls /sys/bus/cpu/devices/ | wc -l)
echo "Performance Settings for CPU"

(
echo -n 0 >  /sys/kernel/mm/ksm/run || true
echo -n 0 > /sys/kernel/mm/ksm/merge_across_nodes || true
sysctl -w kernel.sched_rt_runtime_us=-1 || true

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

# Reduce VM jitter: https://www.kernel.org/doc/Documentation/kernel-per-CPU-kthreads.txt
sysctl vm.stat_interval=120

sysctl -w kernel.watchdog=0
# the kernel's dirty page writeback mechanism uses kthread workers. They introduce
# massive arbitrary latencies when doing disk writes on the host and aren't
# migrated by cset. Restrict the workqueue to use only cpu 0.
echo -n 01 > /sys/bus/workqueue/devices/writeback/cpumask || :
# THP can allegedly result in jitter. Better keep it off.
#echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 0 > /sys/bus/workqueue/devices/writeback/numa || :
) 2>/dev/null 1>/dev/null
