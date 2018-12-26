#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

echo "Using GFX Card:"
echo "QXL"
VNC=$(get_vnc $GFX_VNCPORT $MACHINE_PATH)
QEMU_OPTS+=(
	-device qxl
	$VNC	
	-nographic
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
'{ "execute": "set_password", "arguments": { "protocol": "spice", "password": "secret" } }'
)
