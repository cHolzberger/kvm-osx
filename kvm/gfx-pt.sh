#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

hdr Gfx Passthrough 

./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)
irq=$(cat /sys/bus/pci/devices/$dev/irq)
ROMFILE=$(get_rom $GFXPCI)
XVGA=$(get_xvga $GFXVGA)

echo -e "\tUsing GFX Card:\t$dev"
echo -e "\tIRQ: $irq\tROMFILE: $romfile"
echo -e "\tVGA: $XVGA\tExtra: $GFX_ARGS"

#echo -n "1" > /proc/irq/$irq/smp_affinity_list


QEMU_OPTS+=( 
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR,multifunction=on,host=$GFXPCI.0$GFX_ARGS$ROMFILE$XVGA
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR.0x1,host=$GFXPCI.1
) 

#lspci -s "$GFXPCI"
#echo "Using Additional Args; $GFX_ARGS"

add_vgpu $GFX_ENABLE_VNC $GFX_VGPU $GFX_ENABLE_VNC $GFX_VNCPORT

