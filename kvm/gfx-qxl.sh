#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-device qxl
	-vnc $GFX_VNCPORT,password
	-nographic
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
'{ "execute": "set_password", "arguments": { "protocol": "spice", "password": "secret" } }'
)
