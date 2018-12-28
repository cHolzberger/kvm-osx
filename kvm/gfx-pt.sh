#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh
./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)


ROMFILE=$(get_rom $GFXPCI)
XVGA=$(get_xvga $GFXVGA)

QEMU_OPTS+=( 
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR,multifunction=on,host=$GFXPCI.0$GFX_ARGS$ROMFILE$XVGA
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR.0x1,host=$GFXPCI.1
) 

echo "Using GFX Card:"
lspci -s "$GFXPCI"
echo "Using Additional Args; $GFX_ARGS"

add_vgpu $GFX_ENABLE_VNC $GFX_VGPU $GFX_ENABLE_VNC $GFX_VNCPORT

