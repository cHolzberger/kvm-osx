#!/bin/bash

if [ "x$TERADICI_PCI" != "x" ]; then 

./vfio-bind 0000:${TERADICI_PCI}.0
./vfio-bind 0000:${TERADICI_PCI}.1
#./vfio-bind 0000:${TERADICI_PCI}.2
#./vfio-bind 0000:${TERADICI_PCI}.3
#./vfio-bind 0000:${TERADICI_PCI}.4

QEMU_OPTS+=( 
-device ioh3420,bus=pcie.0,port=3,chassis=3,addr=1f.0,id=pcie-port-teradici
-device vfio-pci,host=$TERADICI_PCI.0,bus=pcie-port-teradici,addr=0.0
-device vfio-pci,host=$TERADICI_PCI.1,bus=pcie-port-teradici,addr=1.0
#-device vfio-pci,host=$TERADICI_PCI.2,bus=pcie-port-teradici,addr=2.0
#-device vfio-pci,host=$TERADICI_PCI.3,bus=pcie-port-teradici,addr=0.3,multifunction=on
#-device vfio-pci,host=$TERADICI_PCI.4,bus=pcie-port-teradici,addr=0.4,multifunction=on
)

echo "Using Teradici Controller:"
lspci -s "$TERADICI_PCI"

fi
