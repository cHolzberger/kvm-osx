#!/bin/bash

./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)

echo "Vendor $vendor Device $device"
echo "Using roms/${vendor}_${device}.rom"
ROMFILE=roms/${vendor}_${device}.rom

#CLOVER_OPTS+=( 	-device vfio-pci,host=$GFXPCI.1,rombar=0,addr=03.1 ) 

if [ -e $ROMFILE ]; then
	echo "GFX PT Using ROM: $ROMFILE"
	CLOVER_OPTS+=(-device vfio-pci,host=$GFXPCI.0,multifunction=on,addr=02.0,x-vga=on,romfile=$ROMFILE)
else
	echo "GFX PT Without ROM"
	CLOVER_OPTS+=(-device vfio-pci,host=$GFXPCI.0,addr=0x02,bus=pci.0,x-vga=on )
fi

echo "Using GFX Card and VNC:"
lspci -s "$GFXPCI"


QEMU_OPTS+=(
	-nographic
	-vga none
#	-vga std
#	-vnc $GFX_VNCPORT,password
)
 
QMP_CMD+=(
#'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
