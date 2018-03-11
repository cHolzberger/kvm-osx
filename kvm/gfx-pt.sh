#!/bin/bash

./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)

echo "Vendor $vendor Device $device"
echo "Using roms/${vendor}_${device}.rom"
ROMFILE=roms/${vendor}_${device}.rom

GFX_ARGS=""
if [ -e $ROMFILE ]; then
	echo "GFX PT Using ROM: $(pwd)/$ROMFILE"
	GFX_ARGS=",romfile=$(pwd)/$ROMFILE"
else
	echo "GFX PT Without ROM"
fi

CLOVER_OPTS+=( 
	-device ioh3420,bus=pcie.0,port=1,chassis=1,addr=1c.0,id=pcie-port-1
	-device vfio-pci,bus=pcie-port-1,host=$GFXPCI.0,multifunction=on,rombar=1,addr=0.0$GFX_ARGS 
) 
#	-device vfio-pci,host=$GFXPCI.1,addr=0.1,bus=pcie-port-1

echo "Using GFX Card:"
lspci -s "$GFXPCI"
echo "Using Additional Args; $GFX_ARGS"

QEMU_OPTS+=(
-vga none
)
 
