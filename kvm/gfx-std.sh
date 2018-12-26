#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

echo "Using GFX Card:"
echo "std"
VNC=$( get_vnc $GFX_VNCPORT $MACHINE_PATH )

QEMU_OPTS+=(
	-vga std
	$VNC
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
