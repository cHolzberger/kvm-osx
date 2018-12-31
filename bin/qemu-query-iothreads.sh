#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config-common

WANT_SEAT=$(echo $1 | cut -d":" -f 2)
WANT_MACHINE=$(echo $1 | cut -d":" -f 1)

MACHINE=${WANT_MACHINE:-"default"}
SEAT=${WANT_SEAT:-"$MACHINE"}

MACHINE_PATH="$VM_PREFIX/$MACHINE"
MACHINE_DISKS="$VM_PREFIX/$MACHINE/disks"

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

if [ ! -e "$MACHINE_PATH/config" ]; then
	echo "Can't load $MACHINE"
	echo "Reason: 'config' does not exist in $MACHINE_PATH"
	exit 2
fi

#LOADING MACHINE CONFIG
source $MACHINE_PATH/config


SOCKET=$MACHINE_PATH/var/control
qmp-send "$SOCKET" '{ "execute": "qmp_capabilities" }\n { "execute": "query-iothreads" }' 
#|  sed -e "s/[,}{]/\n/g" | grep thread-id | cut -d":" -f 2 | xargs echo
