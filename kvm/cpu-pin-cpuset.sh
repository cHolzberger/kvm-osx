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
CPUSET=/dev/cpuset 

source $SCRIPT_DIR/config-machine

$CMD & sleep 5


qemu_pid=$(cat $MACHINE_PATH/var/pid)
echo "CPU Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"
tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' | nc -NU "$SOCKET" |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )

# text to array
USE_CPUS=(${USE_CPUS[*]})

echo "Using CPUs: ${USE_CPUS[*]}"
echo $tasks
i=0

echo "creating $CPUSET/kvm"
test -d $CPUSET/kvm || mkdir $CPUSET/kvm 
DEF_MEMSET=$(cat $CPUSET/mems)
DEF_CPUSET=$(cat $CPUSET/cpus)

echo -n "$DEF_MEMSET" > $CPUSET/kvm/mems
echo -n "$DEF_CPUSET" > $CPUSET/kvm/cpus

echo "creating pinned cpusets"
for c in ${USE_CPUS[*]}; do
	C="$CPUSET/kvm/cpu$c"
	echo "Creating $C"
	test -d $C || mkdir $C
	/bin/echo -n "$DEF_MEMSET" > $C/mems
	/bin/echo -n $c > $C/cpus
	/bin/echo -n 0 > $C/sched_load_balance
done

echo "Pinning $qemu_pid"
/bin/echo -n "$qemu_pid" > $CPUSET/kvm/tasks
renice -15 $qemu_pid
for t in $tasks ; do
	c=${USE_CPUS["$i"]}
	C="$CPUSET/kvm/cpu$c"
	echo "Using Real CPU $c for VCPU $i"
	/bin/echo "$t to $C/tasks"	
	/bin/echo -n $t > $C/tasks
	let i=$i+1
done
