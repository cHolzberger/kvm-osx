#!/bin/bash

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=none"
QCOW2_OPTS="cache=writethrough,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off,cache.direct=on"

: ${INDEX:=0}

: ${DISK_INIT:=true}

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

: ${VBLK_INDEX:=0}
function add_virtio_pci_disk() {
	name=$1
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	QEMU_OPTS+=( 
	-object iothread,id=iothread$name
	-device virtio-blk-pci,drive=${name}HDD,scsi=off,config-wce=off,bootindex=$INDEX,iothread=iothread$name,bus=pcie_root.1,addr=$(printf "%02x" $INDEX)
	-drive id=${name}HDD,if=none,$diskarg
	)
        let INDEX=INDEX+1
        let VBLK_INDEX=VBLK_INDEX+1
	echo "Adding Virtio-PCI Disk: $name"
}

: ${VSCSI_INDEX:=0}
function add_virtio_scsi_disk() {
        name=$1
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	
	if [ "x$VSCSI_INDEX" == "x0" ]; then
		QEMU_OPTS+=(
		-device virtio-scsi-pci,id=vscsi,bus=pcie_root.1,addr=$(printf "%02x" $INDEX)
		)
	fi
                QEMU_OPTS+=(
                -device scsi-hd,bus=vscsi.$VSCSI_INDEX,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$diskarg
                )
	echo "Adding VirtioSCSI Disk: $name"
        let INDEX=INDEX+1
        let VSCSI_INDEX=VSCSI_INDEX+1
}

: ${AHCI_INDEX:=0}
function add_ahci_disk() {
	name=$1
	dformat=raw
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	# -device ahci,id=ahci$INDEX,bus=pcie_root.1
	QEMU_OPTS+=( 
		-device ide-hd,bus=ide.$AHCI_INDEX,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$(diskarg $name)
	)
        let INDEX=INDEX+1
        let AHCI_INDEX=AHCI_INDEX+1
}


