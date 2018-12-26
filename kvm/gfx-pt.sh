#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh
./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)


ROMFILE=$(get_rom $GFXPCI)
XVGA=$(get_xvga $GFXVGA)

QEMU_OPTS+=( 
	-device vfio-pci,bus=$GFXPT_BUS,addr=$GFXPT_ADDR,host=$GFXPCI.0$GFX_ARGS$ROMFILE$XVGA
) 
#	-device vfio-pci,host=$GFXPCI.1,addr=0x0.0x1,bus=pcie-port-1

echo "Using GFX Card:"
lspci -s "$GFXPCI"
echo "Using Additional Args; $GFX_ARGS"


if [[ ! -z "$GFX_ENABLE_VNC" ]];then 
	QEMU_OPTS+=(
        -vga $GFX_VGPU
	-vnc $GFX_VNCPORT,password
	)

QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)

else
	QEMU_OPTS+=(
	-vga none
	)
fi
 
