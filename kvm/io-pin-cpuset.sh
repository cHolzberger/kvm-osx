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

source $MACHINE_PATH/config

echo "IO Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"
tasks=$( qmp-send "$SOCKET" '{ "execute": "qmp_capabilities" }\n { "execute": "query-iothreads" }'  |  sed -e "s/[,}{]/\n/g" | grep thread-id | cut -d":" -f 2 | xargs echo )
tasks=""
echo "Using CPUs: ${IO_CPUS[*]}"
echo $tasks
i=0
C_MEMS="${CPUSET_PREFIX}mems"
C_CPUS="${CPUSET_PREFIX}cpus"
C_TASKS="tasks"
C_SCHED="${CPUSET_PREFIX}sched_load_balance"


                                        
echo "creating pinned cpusets"          
for c in ${IO_CPUS[*]}; do             
        C="$CPUSET/kvm/cpu$c"           
        echo "Creating $C"              
        test -d $C || mkdir $C          
        [[ -e $C/mems ]] && /bin/echo -n "$DEF_MEMSET" > $C/$C_MEMS
        /bin/echo -n $c > $C/$C_CPUS        
        /bin/echo -n 0 > $C/$C_SCHED
done                                          
