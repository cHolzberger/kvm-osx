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
tasks=$( $SCRIPT_DIR/qmp-send $SOCKET '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )

# text to array
USE_CPUS=(${USE_CPUS[*]})

echo "Using CPUs: ${USE_CPUS[*]}"
echo $tasks
i=0

C_MEMS="${CPUSET_PREFIX}mems"
C_CPUS="${CPUSET_PREFIX}cpus"
C_TASKS="tasks"
C_SCHED="${CPUSET_PREFIX}sched_load_balance"


echo "creating $CPUSET/kvm"
test -d $CPUSET/kvm || mkdir $CPUSET/kvm 
[[ -e $CPUSET/$C_MEMS ]] && DEF_MEMSET=$(cat $CPUSET/$C_MEMS)
DEF_CPUSET=$(cat $CPUSET/$C_CPUS)

[[ -e $CPUSET/kvm/$C_MEMS ]] && echo -n "$DEF_MEMSET" > $CPUSET/kvm/$C_MEMS
echo -n "$DEF_CPUSET" > $CPUSET/kvm/$C_CPUS

echo "creating pinned cpusets"
for c in ${USE_CPUS[*]}; do
	C="$CPUSET/kvm/cpu$c"
	echo "Creating $C"
	test -d $C || mkdir $C
	[[ -e $C/$C_MEMS ]] && /bin/echo -n "$DEF_MEMSET" > $C/$C_MEMS
	/bin/echo -n $c > $C/$C_CPUS
	/bin/echo -n 0 > $C/$C_SCHED
done

i=${USE_CPUS[0]}
for t in $tasks ; do                          
        c=$QEMU_CPU                           
        C="$CPUSET/kvm/cpu$i"                 
        echo "Using Real CPU $i for VCPU $i"  
        /bin/echo "$t to $C/$C_TASKS"            
        /bin/echo -n $t > $C/$C_TASKS            
        let i=$i+1                            
done 


C=$CPUSET/qemu
echo "Pinning $qemu_pid to $C"
test -d $C || mkdir $C
let QEMU_CPU=${USE_CPUS[0]}-1

if [ "$QEMU_CPU" == "-1" ]; then
	QEMU_CPU="0"
fi

/bin/echo -n "$DEF_MEMSET" > $C/$C_MEMS
/bin/echo -n $QEMU_CPU > $C/$C_CPUS
/bin/echo -n 0 > $C/$C_SCHED
/bin/echo -n "$qemu_pid" > $C/$C_TASKS

