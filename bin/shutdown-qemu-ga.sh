#!/bin/bash
sleep 5
# openbsd-nc is important! 
SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config-common
source $SCRIPT_DIR/config-machine

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
qemu_pid=$(cat $MACHINE_PATH/var/pid)
 echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "system_powerdown" }' | nc -NU "$SOCKET" 
