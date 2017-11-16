#!/bin/bash

echo "Using GFX Card:"
echo "std"

QEMU_OPTS+=(
	-vga std
	-vnc $GFX_VNCPORT
)
 

