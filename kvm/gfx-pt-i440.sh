#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

RUN_PRE_BOOT+=( 
	vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 
)

ROMFILE=$(get_rom $GFXPCI)
XVGA=$(get_xvga $GFXVGA)
CLOVER_OPTS+=(-device vfio-pci,host=$GFXPCI.0,addr=04.0$ROMFILE$XVGA)

echo "Using GFX Card and VNC:"
lspci -s "$GFXPCI"

VNC=$(get_vnc $GFX_VNCPORT $MACHINE_PATH)

QEMU_OPTS+=(
	-nographic
#	-vga none
	-vga std
	$VNC
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
