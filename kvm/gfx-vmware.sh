#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-vga vmware
	-vnc $GFX_VNCPORT,password
)
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
