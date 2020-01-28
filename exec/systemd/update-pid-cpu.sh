#!/bin/bash
set -ex -o allexport
EXEC_DIR=$(dirname $(readlink -f $0))

source $EXEC_DIR/../../bin/config-machine-cmd

source $EXEC_DIR/lib-cpu.sh

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
SOCKET=$MACHINE_VAR/control
source $SCRIPT_DIR/config-machine

qemu_pid=$(cat $MACHINE_VAR/pid)
echo "CPU Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"

echo $qemu_pid > $VAR_RUN_DIR/$MACHINE-qemu.pid

qmp-send $MACHINE '{ "execute": "query-cpus" }' 
tasks=$( qmp-send $MACHINE '{ "execute": "query-cpus" }' |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )
tasks=( $tasks )
i=0

for t in ${tasks[@]} ; do                          
    CPUNUM=${USE_CPUS[$i]}
		/bin/echo -n "$t" > $VAR_RUN_DIR/vcpu$i.pid
	  systemd-unit-for-pid "$MACHINE" "vcpu$i" "$VAR_RUN_DIR/$MACHINE-vcpu$i.pid"
   let i="($i + 1)"
done 
echo "Done"


