#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-cpu.sh
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
MACHINE_NAME=$MACHINE
SOCKET=$MACHINE_VAR/control
source $MACHINE_PATH/config

IO_CPUS=( 0 1 ) #(${IO_CPUS[*]})

tasks=$( qmp-send "$MACHINE" '{ "execute": "query-iothreads" }'  |  sed -e "s/[,}{]/\n/g" | grep thread-id | cut -d":" -f 2 | xargs echo )
tasks=( $tasks )

for t in ${tasks[@]} ; do   
	echo -n $t > $IOSET_DIR/$C_TASKS
done
