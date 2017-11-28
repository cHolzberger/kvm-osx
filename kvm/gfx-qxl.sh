#!/bin/bash

echo "Using GFX Card:"
echo "VMWare"

QEMU_OPTS+=(
	-device qxl-vga,vgamem_mb=64,ram_size_mb=64,vram_size_mb=16,xres=1024,yres=768
	-spice port=$GFX_SPICEPORT,disable-ticketing,jpeg-wan-compression=never,image-compression=off,streaming-video=all,agent-mouse=on
	-device virtio-serial-pci 
	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 
	-chardev spicevmc,id=spicechannel0,name=vdagent
	-vnc $GFX_VNCPORT
)
 

