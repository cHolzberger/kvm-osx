#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-cpu.sh
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

MACHINE_NAME=$MACHINE
SOCKET=$MACHINE_PATH/var/control

source $SCRIPT_DIR/config-machine

destroy_cpuset "$MACHINE_NAME"
sleep 1

qemu_pid=$(cat $MACHINE_PATH/var/pid)
echo "CPU Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"

# text to array
USE_CPUS=(${USE_CPUS[*]})
#let QEMU_CPU=${USE_CPUS[0]}-1
#if [ "$QEMU_CPU" == "-1" ]; then
	QEMU_CPU="0"
#fi

X_CPU=( $QEMU_CPU 0 1 )
for c in ${USE_CPUS[@]}; do
	X_CPU+=( $c );
done

OIFS=$IFS
IFS=","
echo "Using CPUs: ${USE_CPUS[*]} XCPU: ${X_CPU[*]}"
create_cloned_cpuset ""
create_cloned_cpuset "$MACHINE_NAME" "${X_CPU[*]}"
create_cloned_cpuset "$MACHINE_NAME/qemu" "$QEMU_CPU"
IFS=$OIFS

for c in ${USE_CPUS[@]}; do
	create_cloned_cpuset "$MACHINE_NAME/vcpu$c" "$c"
done

C=$CPUSET_DIR
echo -e "Pinning $CMD_PID to $C"
/bin/echo -n "$CMD_PID" > $C/$C_TASKS

C=$CPUSET_DIR/qemu
echo -e "Pinning QEMU PID $qemu_pid to $C"
echo -e "\tUsing Real CPU $QEMU_CPU for QEMU ($qemu_pid)"  
/bin/echo -n "$qemu_pid" > $C/$C_TASKS

if [[ "$USE_CHRT" == "y" ]]; then
	echo -e "\tSetting SCHED_FIFO and PRIO 90 for QEMU ($qemu_pid)"  
	chrt -f -p 90 $qemu_pid
fi
#-- 
echo "CPUSET for Local CPUs kvm/$MACHINE_NAME"

qmp-send $MACHINE '{ "execute": "query-cpus" }' 
tasks=$( qmp-send $MACHINE '{ "execute": "query-cpus" }' |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )
tasks=( $tasks )
echo ${tasks[@]}
i=0
CPUCOUNT=${#USE_CPUS[@]}
for t in ${tasks[@]} ; do                          
        CPUNUM=${USE_CPUS[$i]}

	C="$CPUSET_DIR/vcpu$CPUNUM"               
	echo -e "\tUsing Real CPU $CPUNUM for VCPU $i ($t) [ $i / $CPUCOUNT]"  
	/bin/echo -e "\tsending pid $t to $C/$C_TASKS"       
        /bin/echo -n $t > "$C/$C_TASKS"          
	sleep 1
        let i="($i + 1)"
done 
echo "Done"


