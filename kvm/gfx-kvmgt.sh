#!/bin/bash

echo "Using GFX Card:"
echo "kvmgt"

GFX_PATH="/sys/bus/pci/devices/0000:00:02.0"
MDEV_PATH="$GFX_PATH/mdev_supported_types/i915-GVTg_V5_4/" 

uuid=$(uuidgen)

/bin/echo -n "$uuid" > "$MDEV_PATH/create"
MDEV_DEVICE="$GFX_PATH/$uuid"

QEMU_OPTS+=(
	-vga qxl
	-vnc $GFX_VNCPORT,password
    	-device vfio-pci,sysfsdev=$MDEV_DEVICE,rombar=0,display=off # for Qemu 2.12 you should add "display=off" option when you create VM without dma-buf. 
)
 
QMP_CMD+=(
'{ "execute": "set_password", "arguments": { "protocol": "vnc", "password": "secret" } }'
)
