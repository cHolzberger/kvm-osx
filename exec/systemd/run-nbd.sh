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

for i in clover system data data1 data2 data3; do
 DISK_VAR="DISK_${i}"
 DISK=${!DISK_VAR}
 
 DISK_TYPE_VAR="DISK_${i}_TYPE"
 DISK_TYPE=${!DISK_TYPE_VAR}
 DISK_FORMAT_VAR="DISK_${i}_FORMAT"
 DISK_FORMAT=${!DISK_FORMAT_VAR}
 DISK_FORMAT=${DISK_FORMAT:-raw}
 SOCK="$MACHINE_VAR/$i.nbd.sock"

 if [[ "$DISK_TYPE" = "nbd" ]]; then
		echo "Starting [NBD Server: $SOCK] for [Disk: $DISK]"
		systemctl stop qemu-${MACHINE/-/__}-disk-$i 2>/dev/null || true
		CMD=( 
				/opt/qemu/bin/qemu-nbd
        --discard=unmap
        --detect-zeroes=unmap
	--persistent 
        --socket="$SOCK"
        --format=raw 
        $DISK 
		)
		systemd-run --no-block --unit=qemu-${MACHINE/-/__}-disk-$i --slice=qemu ${CMD[@]} &
	fi
done
) >&2
