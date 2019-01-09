#!/bin/bash

# The kernel allocates aio memory on demand, and this number limits the
# number of parallel aio requests; the only drawback of a larger limit is
# that a malicious guest could issue parallel requests to cause the kernel
# to set aside memory.  Set this number at least as large as
#   128 * (number of virtual disks on the host)
# Libvirt uses a default of 1M requests to allow 8k disks, with at most
# 64M of kernel memory if all disks hit an aio request at the same time.
sysctl -w fs.aio-max-nr=1048576

### disK PERFORMANcE
ls -d /sys/class/block/nvme*/queue/ | while read i; do
echo $i
	#echo 100 > $i/iosched/read_expire
#	echo 4 > $i/iosched/writes_starved
	echo -n 8192 > $i/read_ahead_kb
	echo -n "1" > $i/rq_affinity

	
done
ls -d /sys/class/block/sd*/queue/ | while read i; do
echo $i
	echo -n "none" > $i/scheduler 
	#echo -n 100 > $i/iosched/read_expire
	#echo -n 4 > $i/iosched/writes_starved
	echo -n 1024 > $i/read_ahead_kb
	echo -n "1" > $i/rq_affinity
done

echo "Setra for disks"
ls -d /dev/sd? | while read i; do
	echo $i
	blockdev --setra 128 $i || true
done

echo "Setra for md"
ls -d /dev/md && for i in /dev/md/*; do
	echo $i
	blockdev --setra 16384 $i
done


echo "Setra for lvm"
ls -d /dev/vg-* && for i in /dev/vg-*/*; do
	echo $i
	blockdev --setra 16384 $i
done

#echo "NVME SMP Affinity"
folders=/proc/irq/*;
for folder in $folders; do
	files="$folder/*";
	for file in $files; do
		if [[ $file == *"nvme"* ]]; then
			echo $file;
#			contents=$(cat $folder/affinity_hint);
#			echo -n $contents > $folder/smp_affinity;
#			cat $folder/smp_affinity;
			echo -n "0-1" > $folder/smp_affinity_list || :
		fi
	done
done

echo "Writeback settings"
echo -n 20000 > /proc/sys/vm/dirty_writeback_centisecs
#sysctl -w vm.vfs_cache_pressure=50 
#sysctl -w vm.dirty_ratio=10
#sysctl -w vm.dirty_background_ratio=25
sysctl -w vm.dirty_bytes=16777216 #16Mb
sysctl -w vm.dirty_background_bytes=835584 #mb
sysctl -w vm.swappiness=1
