#!/bin/bash

./vfio-bind 0000:${USBPCI}.0

QEMU_OPTS+=( 
-device vfio-pci,host=$USBPCI.0,bus=root.1 )

echo "Using USB Controller:"
lspci -s "$USBPCI"
