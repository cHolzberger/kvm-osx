#!/bin/bash

echo "Using GFX Card:"
echo "std"

lp="$MACHINE_VAR/debugcon.log"
QEMU_OPTS+=(
	-vga none
	-nographic
	-debugcon file:$lp -global isa-debugcon.iobase=0x402
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
