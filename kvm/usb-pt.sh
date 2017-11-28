#!/bin/bash

./vfio-bind 0000:${USBPCI}.0

QEMU_OPTS+=( 
-device ioh3420,bus=pcie.0,port=2,chassis=2,addr=1d.0,id=pcie-port-2
-device vfio-pci,host=$USBPCI.0,bus=pcie-port-2,addr=0.0
)

echo "Using USB Controller:"
lspci -s "$USBPCI"
