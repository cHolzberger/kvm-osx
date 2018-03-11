#!/bin/bash

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=none"
QCOW2_OPTS="cache=writethrough,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off,cache.direct=on"

INDEX=0

DISK_INIT=true

if [ $DISK_INIT == true ]; then
	#add own root complex
	QEMU_OPTS+=(
		-device ioh3420,id=pcie_root.1,bus=pcie.0
	)
	DISK_INIT=false
fi

function diskarg() {
	name=$1

        if [ -e "$DISKS_PATH/$name.raw" ]; then	
		echo "file=$DISKS_PATH/$name.raw,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.qcow2" ]; then
		echo "file=$DISKS_PATH/$name.qcow2,format=qcow2,$QCOW2_OPTS"
	else
		echo "err"
	fi
}

function add_virtio_pci_disk() {
	name=$1
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	QEMU_OPTS+=( 
	-object iothread,id=iothread$name
	-device virtio-blk-pci,drive=${name}HDD,scsi=off,config-wce=off,bootindex=0,iothread=iothread$name,bus=pcie_root.1
	-drive id=${name}HDD,if=none,$diskarg
	)
        let INDEX=INDEX+1
	echo "Adding Virtio-PCI Disk: $name"
}

function add_virtio_scsi_disk() {
        name=$1
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi

                dformat=raw
                QEMU_OPTS+=(
                -device virtio-scsi-pci,id=vscsi-$name,bus=pcie_root.1,slot=$INDEX
                -device scsi-hd,bus=vscsi-$name.0,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$diskarg
                )
	echo "Adding VirtioSCSI Disk: $name"
        let INDEX=INDEX+1
}


function add_ahci_disk() {
	name=$1
	dformat=raw
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi

	QEMU_OPTS+=( 
		-device ahci,id=ahci$INDEX,bus=pcie_root.1
		-device ide-hd,bus=ahci$INDEX.0,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$(diskarg $name)
	)
        let INDEX=INDEX+1
}


