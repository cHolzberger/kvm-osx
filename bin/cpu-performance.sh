#!/bin/bash

# The kernel allocates aio memory on demand, and this number limits the
# number of parallel aio requests; the only drawback of a larger limit is
# that a malicious guest could issue parallel requests to cause the kernel
# to set aside memory.  Set this number at least as large as
#   128 * (number of virtual disks on the host)
# Libvirt uses a default of 1M requests to allow 8k disks, with at most
# 64M of kernel memory if all disks hit an aio request at the same time.
sysctl -w fs.aio-max-nr=1048576

# this is strange, helps cpu stalls
sysctl -w vm.min_free_kbytes=131072
### disK PERFORMANcE
ls -d /sys/class/block/nvme*/queue/ | while read i; do
echo $i
	#echo 100 > $i/iosched/read_expire
#	echo 4 > $i/iosched/writes_starved
	echo -n 512 > $i/read_ahead_kb
	echo -n "2" > $i/rq_affinity
done
ls -d /sys/class/block/sd*/queue/ | while read i; do
echo $i
#	echo 100 > $i/iosched/read_expire
#	echo 4 > $i/iosched/writes_starved
	echo -n 512 > $i/read_ahead_kb
	echo -n "2" > $i/rq_affinity

done

echo "Numa"
echo 1 > /proc/sys/kernel/numa_balancing || true

echo "Writeback settings"
echo 10000 > /proc/sys/vm/dirty_writeback_centisecs
sysctl -w vm.dirty_ratio=50
sysctl -w vm.dirty_background_ratio=1


CPUCOUNT=$(ls /sys/bus/cpu/devices/ | wc -l)

echo "enable ksm for host"
echo -n 1 >  /sys/kernel/mm/ksm/run
echo -n 0 > /sys/kernel/mm/ksm/merge_across_nodes

if [ -e /sys/devices/system/cpu/intel_pstate/min_perf_pct ]; then
	echo "Setting minimum performance"
	echo -n 66 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
fi
echo "Found $CPUCOUNT cpus"
echo "Setting performance governor"

ls /sys/bus/cpu/devices | while read cpu; do
	echo "Setting: " $cpu
	echo -n "performance" > /sys/bus/cpu/devices/$cpu/cpufreq/scaling_governor
done
