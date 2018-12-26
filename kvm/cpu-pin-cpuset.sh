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

i=${USE_CPUS[0]}
for t in $tasks ; do                          
        c=$QEMU_CPU                           
        C="$CPUSET/kvm/cpu$i"                 
        echo "Using Real CPU $i for VCPU $i"  
        /bin/echo "$t to $C/tasks"            
        /bin/echo -n $t > $C/tasks            
        let i=$i+1                            
done 


C=$CPUSET/qemu
echo "Pinning $qemu_pid to $C"
test -d $C || mkdir $C
let QEMU_CPU=${USE_CPUS[0]}-1

if [ "$QEMU_CPU" == "-1" ]; then
	QEMU_CPU="0"
fi

/bin/echo -n "$DEF_MEMSET" > $C/mems
/bin/echo -n $QEMU_CPU > $C/cpus
/bin/echo -n 0 > $C/sched_load_balance
/bin/echo -n "$qemu_pid" > $C/tasks

