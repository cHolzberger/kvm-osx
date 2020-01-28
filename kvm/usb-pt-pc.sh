#!/bin/bash

PCI_PT+=(
	$USBPCI_1
	$USBPCI_2
	$USBPCI_3
)

for dev in "${PCI_PT[@]}" ; do 
	echo "PT=> $dev"
	addr=$(echo $dev | cut -d":" -f 2)
	QEMU_OPTS+=(
		-device vfio-pci,host=$dev.0,bus=pci.0,addr=$addr
	)
	
	RUN_PRE_BOOT+=(
		vfio-bind 0000:${dev}.0
	)
done
