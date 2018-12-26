#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
# must be cache=directsync for virtio-blk
RAW_OPTS_default_="aio=native,cache.direct=on,cache=none,discard=unmap"
RAW_OPTS_virtio_blk_pci="aio=native,cache.direct=on,cache=none,discard=unmap"
#RAW_OPTS_virtio_blk_pci="aio=native,cache.direct=on,cache=directsync,discard=unmap"

QCOW2_OPTS="cache=writethrough,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off,cache.direct=on"

: ${INDEX:=0}

: ${DISK_INIT:=true}

if [ $DISK_INIT == true ]; then
	#add own root complex
	QEMU_OPTS+=(
	#	-device ioh3420,id=pcie_root.1,bus=pcie.0
        #        -device pcie-root-port,port=2,chassis=4,addr=1a.0,id=storport
	)
	DISK_INIT=false
fi

function diskarg() {
	name=$1
	controller=RAW_OPTS_${2:default}
	
	RAW_OPTS=${!controller}
        if [ -e "$DISKS_PATH/$name.raw" ]; then	
		echo "file=$DISKS_PATH/$name.raw,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.qcow2" ]; then
		echo "file=$DISKS_PATH/$name.qcow2,format=qcow2,$QCOW2_OPTS"
	else
		echo "err"
	fi
}

# Use case: passathrough host device as pcie disk
# sometimes giving errors oon windows
: ${VBLK_INDEX:=0}
function add_virtio_pci_disk() {
	name=$1

	diskarg=$(diskarg $name virtio_blk_pci)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	QEMU_OPTS+=( 
	-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
	-device virtio-blk-pci,ioeventfd=on,num-queues=8,drive=${name}HDD,scsi=off,bootindex=$INDEX,iothread=iothread$name
	-drive id=${name}HDD,if=none,$diskarg
	)
        let INDEX=INDEX+1
        let VBLK_INDEX=VBLK_INDEX+1
	echo "Adding Virtio-PCI Disk: $name -> $diskarg"
}


# use case: passthrough host wwn to guest
# not working atm
# see https://wiki.libvirt.org/page/Vhost-scsi_target
: ${VHSCSI_INDEX:=0}
function add_vhost_scsi_disk() {
        name=$1
	diskarg=$(diskarg $name)

	DISK_SERIAL=$HDD_SERIAL_BASE$INDEX
	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	
	if [ "x$VHSCSI_INDEX" == "x0" ]; then
		QEMU_OPTS+=(
		-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
		-device vhost-scsi-pci,ioeventfd=on,iothread=iothread$name,num_queues=8,id=vscsi
		)
	fi
	
                QEMU_OPTS+=(
                -device scsi-hd,bus=vscsi.0,serial=$DISK_SERIAL,scsi-id=$VSCSI_INDEX,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$diskarg
                )
	echo "Adding VhostSCSI Disk: $name"
        let INDEX=INDEX+1
        let VHSCSI_INDEX=VHSCSI_INDEX+1
}

# Use case: passthrough host device as scsi controller + disks to the vm

: ${VSCSI_INDEX:=0}
function add_virtio_scsi_disk() {
        name=$1
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	DISK_SERIAL=$HDD_SERIAL_BASE$INDEX
	
	if [ "x$VSCSI_INDEX" == "x0" ]; then
		QEMU_OPTS+=(
		-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
		-device virtio-scsi-pci,ioeventfd=on,bus=$SCSI_BUS,addr=$SCSI_ADDR,iothread=iothread$name,num_queues=4,id=vscsi
		)
	fi
                QEMU_OPTS+=(
                -device scsi-hd,channel=0,scsi-id=0,bus=vscsi.0,lun=$VSCSI_INDEX,serial=$DISK_SERIAL,drive=${name}HDD,bootindex=1 
		-drive id=${name}HDD,if=none,$diskarg
                )
	echo "Adding VirtioSCSI Disk: $name"
        let INDEX=INDEX+1
        let VSCSI_INDEX=VSCSI_INDEX+1
}

# Use case: compatibility / macos passthrough disk as ahci controller + disk 
: ${AHCI_INDEX:=0}
function add_ahci_disk() {
	name=$1
	dformat=raw
	diskarg=$(diskarg $name)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	QEMU_OPTS+=( 
		-device ich9-ahci,id=ahci$INDEX
		-device ide-hd,bus=ahci$INDEX.$AHCI_INDEX,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,$(diskarg $name)
	)
        let INDEX=INDEX+1
        let AHCI_INDEX=AHCI_INDEX+1
}


