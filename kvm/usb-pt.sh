#!/bin/bash

./vfio-bind 0000:${USBPCI}.0

QEMU_OPTS+=( 
	-device ioh3420,bus=pcie.0,slot=2,id=root.2 
-device vfio-pci,host=$USBPCI.0,bus=root.2,rombar=0 )

echo "Using USB Controller:"
lspci -s "$USBPCI"
