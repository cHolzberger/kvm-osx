#!/bin/bash

QEMU_OPTS+=(
#-device ich9-usb-ehci1,id=usb \
#-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \
#-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \
#-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \
#-device nec-usb-xhci,id=usb,addr=0x5
) 

echo "Using USB Controller:"
echo "Virt"
