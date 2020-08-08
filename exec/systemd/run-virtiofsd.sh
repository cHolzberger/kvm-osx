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
for i in clover system data data1 data2 data3; do
 DISK_VAR="DISK_${i}"
 DISK=${!DISK_VAR}
 
 DISK_MODE_VAR="DISK_${i}_MODE"
 DISK_MODE=${!DISK_MODE_VAR}
 DISK_FORMAT_VAR="DISK_${i}_FORMAT"
 DISK_FORMAT=${!DISK_FORMAT_VAR}
 DISK_FORMAT=${DISK_FORMAT:-raw}

 DISK_PATH_VAR="DISK_${i}_PATH"
 DISK_PATH=${!DISK_PATH_VAR}

 SOCK="$MACHINE_VAR/$i.virtiofsd.sock"

 if [[ "$DISK_MODE" = "virtiofsd" ]]; then
		echo "Starting [Virtiofsd Server: $SOCK] for [Disk: $DISK]"
	
		systemctl stop qemu-${MACHINE/-/__}-disk-$i 2>/dev/null || true
		systemctl reset-failed qemu-${MACHINE/-/__}-disk-$i 2>/dev/null || true
		rm $SOCK || true
		CMD=( 
			/opt/qemu/libexec/virtiofsd 
			-f 
			--socket-path=$SOCK
			-o source=$DISK_PATH
			-o cache=auto 
			-o writeback 
			-o no_posix_lock
#			-o xattr
		)
		systemd-run --no-block --unit=qemu-${MACHINE/-/__}-disk-$i --slice=qemu ${CMD[@]} &
	fi
done
sleep 2
) >&2
