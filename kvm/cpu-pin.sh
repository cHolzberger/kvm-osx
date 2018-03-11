#!/bin/bash
sleep 5
# openbsd-nc is important! 

if [ "x$MACHINE" == "x" ]; then
	echo "Usage:"
	echo "$0 [machine-name]"
	exit 3
fi

if [ ! -d "$MACHINE_PATH" ]; then
	echo "Machine $MACHINE does not exists"
	echo "Reason: $MACHINE_PATH does not exist"
	exit 1
fi

SOCKET=$MACHINE_PATH/var/control
CMD=$MACHINE_PATH/run
source $MACHINE_PATH/config
echo "NUMA Pinning for $MACHINE with socket $SOCKET"
echo "Using NUMA Node: ${CPU_NUMA_NODE}"

_c=$(join_arr ${USE_CPUS[@]})
if [ "x$USE_IO_CPU" != "x" ]; then
	QEMU_CPUS="$USE_IO_CPU,$_c"
else
	QEMU_CPUS=$_c
fi

#renice -15 $qemu_pid
#/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_IO_CPU} -e \
#	numactl --cpunodebind="$CPU_NUMA_NODE" --membind="$CPU_NUMA_NODE" \
$CMD &
sleep 5

qemu_pid=$(cat $MACHINE_PATH/var/pid)
echo "CPU Pinning for $MACHINE with socket $SOCKET"
echo "Using IO CPU: $USE_IO_CPU"
echo "Using Guest CPU(s): $QEMU_CPUS" 
echo "Querying QEMU for VCPU Pids"
tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' | nc -NU "$SOCKET" |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )
i=0

#echo "setting qemu prio"
#/srv/kvm/OSX-KVM/bin/chrt -a --rr --pid 10 $qemu_pid

#/srv/kvm/OSX-KVM/bin/schedtool -a $USE_IO_CPU $qemu_pid
#renice -15 $qemu_pid
for t in $tasks ; do
	echo "Using Real CPU ${USE_CPUS[$i]} for VCPU $i"
	/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[$i]}  $t
	let i=$i+1
done
