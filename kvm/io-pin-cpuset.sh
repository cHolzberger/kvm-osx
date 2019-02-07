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
SOCKET=$MACHINE_PATH/var/control
source $MACHINE_PATH/config

IO_CPUS=( 0 1 ) #(${IO_CPUS[*]})

OIFS=$IFS
IFS=,

create_cloned_cpuset "$MACHINE_NAME/io" "${IO_CPUS[*]}"

IOSET_DIR="$CPUSET_DIR/io"
S_C="${IO_CPUS[*]}"

IFS=$OIFS

tasks=$( qmp-send "$MACHINE" '{ "execute": "query-iothreads" }'  |  sed -e "s/[,}{]/\n/g" | grep thread-id | cut -d":" -f 2 | xargs echo )
tasks=( $tasks )

for t in ${tasks[@]} ; do   
	echo -e "\tAssigning IO Thread $t to $IOSET_DIR/$C_TASKS"
	echo -n $t > $IOSET_DIR/$C_TASKS
done
