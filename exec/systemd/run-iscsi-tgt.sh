#!/bin/bash
(
set -e -o allexport
EXEC_DIR=$(dirname $(readlink -f $0))

source $EXEC_DIR/../../bin/config-machine-cmd

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

set -e 
IFS="$OIFS"
# set dma
exec 10> /dev/cpu_dma_latency
echo -e -n '10' >&10

		echo "" > /etc/tgt/conf.d/$MACHINE.conf
for i in clover system data data1 data2 data3; do
 DISK_VAR="DISK_${i}"
 DISK=${!DISK_VAR}
 
 DISK_TYPE_VAR="DISK_${i}_TYPE"
 DISK_TYPE=${!DISK_TYPE_VAR}
 IQN="$MACHINE-$i"
 if [[ "$DISK_TYPE" = "iscsi-tgt" ]]; then
		echo "Starting [TGT ISCSI Server: $IQN] for [Disk: $DISK]" 
		tgt-setup-lun -n $IQN -d $DISK || true
	fi
done

) >&2
