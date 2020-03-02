#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-gfx.sh

echo "Using VGPU: std/vmware"
	GFX_VGPU=${GFX_VGPU:-qxl}
	add_vgpu "qxl" "$GFX_VGPU" "true" "$GFX_VNCPORT"
#)
