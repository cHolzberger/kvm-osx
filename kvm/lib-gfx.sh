#!/bin/bash

function get_xvga() {
	if [ "$1" == "on" ]; then 
		echo ",x-vga=on" 
	fi
}

function get_rom () {
	GFXPCI=$1
	dev=0000:${GFXPCI}.0
	vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
	device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)
	svendor=$(cat /sys/bus/pci/devices/$dev/subsystem_vendor | sed -e s/0x//)
	sdevice=$(cat /sys/bus/pci/devices/$dev/subsystem_device | sed -e s/0x//)
	ROMFILE=roms/${vendor}_${device}-${svendor}_${sdevice}.rom
	ROMFILE_SHORT=roms/${vendor}_${device}.rom


	echo "Looking for $ROMFILE_SHORT" 1>&2
	echo "Looking for $ROMFILE" 1>&2
	if [ -e $ROMFILE ]; then
		echo "Using  $ROMFILE" 1>&2
		echo ",romfile=$ROMFILE"
	elif [ -e $ROMFILE_SHORT ]; then
		echo "Using $ROMFILE_SHORT" 1>&2
		echo ",romfile=$ROMFILE_SHORT"
	fi
}
