#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-vga vmware
	-vnc $GFX_VNCPORT
)
 
