#!/bin/bash

source $SCRIPT_DIR/../kvm/lib-pci.sh

RUN_PRE_BOOT+=(
vfio-bind 0000:${USBPCI}.0
)

add_vpci USBPCI_BUS $USB_ROOT_PORT
QEMU_OPTS+=( 
#-device ioh3420,bus=pcie.0,port=2,chassis=2,addr=1e.0,id=pcie-port-2
-device vfio-pci,host=$USBPCI.0,bus=$USBPCI_BUS,addr=0.0,rombar=1
)


if [ "x$USBPCI_1" != "x" ]; then
add_vpci USBPCI_BUS $USB_ROOT_PORT
QEMU_OPTS+=(
-device vfio-pci,host=$USBPCI_1.0,bus=$USBPCI_BUS,addr=0,rombar=1
)

RUN_PRE_BOOT+=(
vfio-bind 0000:${USBPCI_1}.0
)

fi
if [ "x$USBPCI_2" != "x" ]; then
add_vpci USBPCI_BUS $USB_ROOT_PORT
QEMU_OPTS+=(
-device vfio-pci,host=$USBPCI_2.0,bus=$USBPCI_BUS,addr=0.0,rombar=1
)

RUN_PRE_BOOT+=(
vfio-bind 0000:${USBPCI_2}.0
)
fi


echo "Using USB Controller:"
lspci -s "$USBPCI"
