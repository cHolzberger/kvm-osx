#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-vga qxl
	-spice port=5900,addr=127.0.0.1,disable-ticketing 
	-device virtio-serial-pci 
	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 
	-chardev spicevmc,id=spicechannel0,name=vdagent
)
 

	#-vnc $GFX_VNCPORT
