#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh

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

function get_vnc() {
GFX_VNCPORT="$1"
MACHINE_PATH="$2"
TLS=""
echo "Certs in $MACHINE_PATH/cert" 1>&2
if [ -e $MACHINE_PATH/cert ]; then
	TLS=",tls-creds=tls0"
	echo -n "-object tls-creds-x509,verify-peer=no,id=tls0,endpoint=server,dir=$MACHINE_PATH/cert "
fi
echo -n "-vnc $GFX_VNCPORT,password$TLS"

}
