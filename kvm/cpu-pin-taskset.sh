#!/bin/bash

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


CMD=$MACHINE_PATH/run
SOCKET=$MACHINE_PATH/var/control

source $MACHINE_PATH/config

qemu_pid=$(cat $MACHINE_PATH/var/pid)
echo "CPU Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"
tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' | nc -NU "$SOCKET" |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )



echo "Using CPUs: ${USE_CPUS[*]}"
echo $tasks
i=0

#echo "setting qemu prio"
#/srv/kvm/OSX-KVM/bin/chrt -a --rr --pid 10 $qemu_pid

renice -15 $qemu_pid
for t in $tasks ; do
	echo "Using Real CPU ${USE_CPUS[$i]} for VCPU $i"
	#taskset -pc ${USE_CPUS[$i]} $t
	# be nice to cpu threads ;)
	echo "Setting CPU Tasks priority"

	/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[$i]}  -n -10 $t
	echo /srv/kvm/bin/schedtool -a ${USE_CPUS[$i]} -n -10 $t
	#ionice -c 2 -n 3 -p $t
	let i=$i+1
done
