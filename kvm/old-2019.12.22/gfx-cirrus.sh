#!/bin/bash

echo "Using GFX Card:"
echo "std"

QEMU_OPTS+=(
	-vga cirrus
	-vnc $GFX_VNCPORT,password
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
