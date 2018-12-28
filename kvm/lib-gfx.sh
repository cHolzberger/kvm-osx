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
	ROMFILE=$SCRIPT_DIR/../roms/${vendor}_${device}-${svendor}_${sdevice}.rom
	ROMFILE_SHORT=$SCRIPT_DIR/../roms/${vendor}_${device}.rom


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

function add_vgpu() {
GFX_ENABLE_VGPU=$1
GFX_VGPU=$2
GFX_ENABLE_VNC=$3
GFX_VNCPORT=$4

if [[ $GFX_ENABLE_VGPU == "std" ]]; then
	QEMU_OPTS+=(
		-vga $GFX_VGPU
	)
elif [[ ! -z "$GFX_ENABLE_VGPU" ]];then 
	QEMU_OPTS+=(
	-vga none
        -device $GFX_VGPU
	)

else
	QEMU_OPTS+=(
	-vga none
	)
fi

if [[ ! -z "$GFX_ENABLE_VNC" ]]; then
	QEMU_OPTS+=(
	-vnc $GFX_VNCPORT,password
	)

	QMP_CMD+=(
	'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
	)
fi
}
