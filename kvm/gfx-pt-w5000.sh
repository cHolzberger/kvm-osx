#!/bin/bash

./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)

echo "Vendor $vendor Device $device"
echo "Using roms/${vendor}_${device}.rom"
ROMFILE=roms/${vendor}_${device}.rom

CLOVER_OPTS+=( -device ioh3420,bus=$GFXPT_BUS,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 )
#CLOVER_OPTS+=( 	-device vfio-pci,host=$GFXPCI.1,addr=02.0,bus=root.1 ) 
if [ -e $ROMFILE ]; then
	echo "GFX PT Using ROM: $ROMFILE"
	CLOVER_OPTS+=(-device vfio-pci,host=$GFXPCI.0,bus=root.1,multifunction=on,addr=00.0,romfile=$ROMFILE)
	CLOVER_OPTS+=(-device vfio-pci,host=$GFXPCI.1,bus=root.1,addr=00.1)
else
	echo "GFX PT Without ROM"
	CLOVER_OPTS+=(-device vfio-pci,x-pci-sub-vendor-id=1002,x-pci-sub-device-id=6809,host=$GFXPCI.0,bus=root.1,multifunction=on,addr=00.0)
fi

echo "Using GFX Card and VNC:"
lspci -s "$GFXPCI"

QEMU_OPTS+=(
	-vga std
#	-device bochs-display
	-vnc $GFX_VNCPORT,password
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
