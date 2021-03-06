#!/bin/bash

source $SCRIPT_DIR/../kvm/lib-pt.sh

function hdr() {
echo "==== $@ ====="
}

function ftr() {
echo "|............|"
}


function get_xvga() {
	if [ "$1" == "on" ]; then 
		echo ",x-vga=on" 
	fi
}

function get_rom () {
	GFXPCI="$1"
	dev="0000:${GFXPCI}.0"
	vendor=$( cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x// )
	device=$( cat /sys/bus/pci/devices/$dev/device | sed -e s/0x// )
	svendor=$( cat /sys/bus/pci/devices/$dev/subsystem_vendor | sed -e s/0x// )
	sdevice=$( cat /sys/bus/pci/devices/$dev/subsystem_device | sed -e s/0x// )
	
#	ROMFILE="$SCRIPT_DIR/../roms/${vendor}_${device}-${svendor}_${sdevice}.rom"
#	ROMFILE_SHORT="$SCRIPT_DIR/../roms/${vendor}_${device}.rom"

#	echo "Looking for ${ROMFILE_SHORT}" 1>&2
	echo "" 1>&2
	echo '====> GFX ROM LOOKUP' 1>&2
	echo "Looking for $vendor:$device $svendor:$sdevice" 1>&2
	ROM_SHA1=$( cat $SCRIPT_DIR/../roms/table | grep -v "^\#" | grep "$vendor:$device $svendor:$sdevice" | cut -d">" -f 2 | xargs echo)
	ROMFILE="$( realpath $SCRIPT_DIR/../roms/$ROM_SHA1 || echo -n '' )"

	if [[ -n $ROM_SHA1 && -e "$ROMFILE" ]]; then
		echo "Using  $ROMFILE" 1>&2
		echo ",romfile=$ROMFILE"
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

#if [[ ! -z "$GFX_ENABLE_VGPU" ]] && [[ -z "$GFX_VGPU" ]]; then
#	echo "add_vgpu: GFX_ENABLE_VGPU specified but GFX_VGPU missing"
#	exit -1
#fi

if [[ ! -z "$GFX_ENABLE_VNC" ]] && [[ -z "$GFX_VNCPORT" ]]; then
	echo "add_vgpu: GFX_ENABLE_VNC specified but GFX_VNCPORT missing"
	exit -1
fi

if [[ ! -z "$GFX_ENABLE_VNC" ]]; then
	QEMU_OPTS+=(
	-vnc $GFX_VNCPORT,password,lossy,share=force-shared
	-usb -device usb-kbd -device usb-tablet 
	)

	QMP_CMD+=(
	'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
	)
fi
}

if [[ "$GFX_ENABLE_VGPU" == "std" ]]; then
	QEMU_OPTS+=(
		-vga $GFX_VGPU
	#	-display egl-headless
	)
elif [[ "$GFX_ENABLE_VGPU" == "sec" ]]; then
	QEMU_OPTS+=(
		-device secondary-vga
	)
elif [[ "$GFX_ENABLE_VGPU" == "bochs-display" ]]; then
	QEMU_OPTS+=(
		-device bochs-display
	)
elif [[ "$GFX_ENABLE_VGPU" == "qxl" ]]; then
	QEMU_OPTS+=(
		-vga qxl
	)
fi

if [[ -n "$GFXPCI" ]]; then 
#	QEMU_CFG+=(
#	  -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
#	)

	ROMFILE=$(get_rom $GFXPCI)
	QEMU_OPTS+=(
#	-vga none
#	-device VGA,edid=on,xres=1920,yres=1200
  	-device vfio-pci-nohotplug,bus=gpu.1,addr=0x0.0,multifunction=on,host=$GFXPCI.0$ROMFILE$GFX_ARGS
  #,rombar=1
  #-device $GFX_VGPU,bus=gpu.1,addr=0x0.0,slot=0,rombar=5
	)
else
	QEMU_OPTS+=(
	)
fi


