#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

QEMU_CFG+=(
  -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
)

hdr Gfx Passthrough 

dev=0000:${GFXPCI}.0
audio_dev="0000:${GFXPCI}.1"
dev_path="/sys/bus/pci/devices/$dev"
audio_dev_path="/sys/bus/pci/devices/$audio_dev"

vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)
irq=$(cat /sys/bus/pci/devices/$dev/irq)
ROMFILE=$(get_rom $GFXPCI)
XVGA=$(get_xvga $GFXVGA)


if [[ ! -e "$dev_path" ]]; then
	echo "gfx-pt: cant find device $dev_path"
	exit -1
else 
./vfio-bind $dev

QEMU_OPTS+=( 
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR,multifunction=on,host=$GFXPCI.0$GFX_ARGS$ROMFILE$XVGA
)
fi

if [[ ! -e "$audio_dev_path" ]]; then
	echo "gfx-pt: no audio device for $dev"
else 

	./vfio-bind $audio_dev
	
QEMU_OPTS+=( 
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR.0x1,host=$GFXPCI.1
	)
fi

echo -e "\tUsing GFX Card:\t$dev"
echo -e "\tIRQ: $irq\tROMFILE: $romfile"
echo -e "\tVGA: $XVGA\tExtra: $GFX_ARGS"

#echo -n "1" > /proc/irq/$irq/smp_affinity_list

#lspci -s "$GFXPCI"
#echo "Using Additional Args; $GFX_ARGS"

add_vgpu "$GFX_ENABLE_VNC" "$GFX_VGPU" "$GFX_ENABLE_VNC" "$GFX_VNCPORT"

