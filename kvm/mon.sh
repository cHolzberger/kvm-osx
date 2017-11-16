#!/bin/bash

MON_PATH="$VM_PREFIX/$MACHINE/var"

QEMU_OPTS+=(	
 -qmp unix:$MON_PATH/control,server,nowait
 -monitor unix:$MON_PATH/monitor,server,nowait
 -chardev socket,id=serial0,path=$MON_PATH/console,server,nowait
 -serial chardev:serial0
)

# Guest Agent
QEMU_OPTS+=(
 -chardev socket,path=$MON_PATH/qga,server,nowait,id=qga0
 -device virtio-serial
 -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0
)
