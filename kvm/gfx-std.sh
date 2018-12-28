#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

echo "Using VGPU: std/vmware"
if [[ "$BIOS" == "seabios" ]] || [[ "$GFX_ENABLE_VGPU" == "std" ]]; then
	add_vgpu "std" "std" "true" "$GFX_VNCPORT"
else
	add_vgpu "true" "bochs-display" "true" "$GFX_VNCPORT"
fi

#echo "std"
#VNC=$( get_vnc $GFX_VNCPORT $MACHINE_PATH )

#QEMU_OPTS+=(
#	-vga std
#	$VNC
#)
 
#QMP_CMD+=(
#'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
#)
