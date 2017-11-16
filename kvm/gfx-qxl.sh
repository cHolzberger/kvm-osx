#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-vga qxl
	-spice port=$GFX_SPICEPORT,disable-ticketing,jpeg-wan-compression=never,image-compression=off,streaming-video=all,agent-mouse=on
	-device virtio-serial-pci 
	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 
	-chardev spicevmc,id=spicechannel0,name=vdagent
	-vnc $GFX_VNCPORT
)
 

