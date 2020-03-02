#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

echo "Using VGPU: std/vmware"

if [[ "$BIOS" == "seabios" ]] || [[ "$GFX_ENABLE_VGPU" == "std" ]]; then
	GFX_VGPU=${GFX_VGPU:-std}
	add_vgpu "std" "$GFX_VGPU" "true" "$GFX_VNCPORT"

elif [[ "$GFX_ENABLE_VGPU" == "qxl" ]]; then
	GFX_VGPU=${GFX_VGPU:-qxl}
	add_vgpu "qxl" "$GFX_VGPU" "true" "$GFX_VNCPORT"

else
	GFX_VGPU=${GFX_VGPU:-"vmware-svga"}
	add_vgpu "true" "$GFX_VGPU" "true" "$GFX_VNCPORT"
	#add_vgpu "true" "bochs-display" "true" "$GFX_VNCPORT"
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
