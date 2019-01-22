#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
# must be cache=directsync for virtio-blk
RAW_OPTS_default_="aio=native,cache.direct=on,cache=none,discard=unmap"
RAW_OPTS_virtio_blk_pci="aio=native,cache.direct=on,cache=none,discard=unmap"
RAW_OPTS_virtio_scsi_pci="aio=native,cache.direct=on,cache=writethrough"

CONTROLLER_OPTS_default=""
CONTROLLER_OPTS_virtio_scsi_pci="num_queues=4"

QCOW2_OPTS="cache=writethrough,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off,cache.direct=on"

		export LIBISCSI_CHAP_USERNAME 
		export LIBISCSI_CHAP_PASSWORD 
		export LIBISCSI_TARGET_CHAP_USERNAME 
		export LIBISCSI_TARGET_CHAP_PASSWORD
	
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
	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}

	if [ ! -z "$ISCSI_TARGET" ]; then
		echo "file=$ISCSI_TARGET,format=raw,$RAW_OPTS"
        elif [ -e "$DISKS_PATH/$name.raw" ]; then	
		echo "file=$DISKS_PATH/$name.raw,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.qcow2" ]; then
		echo "file=$DISKS_PATH/$name.qcow2,format=qcow2,$QCOW2_OPTS"
	else
		echo "err"
	fi
}

function devicearg() {
	name=$1
	DISK_SERIAL="$2"
	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}


	if [ ! -z "$ISCSI_TARGET" ]; then
		echo "scsi-block"
	else 
		echo "scsi-hd,serial=$DISK_SERIAL"
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
	-device virtio-blk-pci,ioeventfd=on,num-queues=8,drive=${name}HDD,scsi=off,bootindex=$INDEX,iothread=iothread$name,multifunction=on
	-drive id=${name}HDD,if=none,$diskarg
	)
        let INDEX=INDEX+1
        let VBLK_INDEX=VBLK_INDEX+1
	echo "Adding Virtio-PCI Disk: $name -> $diskarg"
}

# Use case: passthrough host device as scsi controller + disks to the vm
# vhost-scsi-pci

: ${VSCSI_INDEX:=0}
function add_virtio_scsi_disk() {
        name=$1
	DISK_SERIAL=$HDD_SERIAL_BASE$INDEX
	diskarg=$(diskarg $name virtio_scsi_pci)
	devicearg=$(devicearg $name $DISK_SERIAL)
	conarg=$CONTROLLER_ARG_virtio_scsi_pci
	
	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	let PCI_INDEX=$VSCSI_INDEX+1
	echo "Creating vrtio-scsi-pci - $SCSI_CONTROLLER (vscsi$VSCSI_INDEX) BUS: $SCSI_BUS ADDR: $SCSI_ADDR"
	
	if [[ "x$VSCSI_INDEX" == "x0" ]] && [[ "$SCSI_CONTROLLER" != "multi" ]]; then
		CONTROLLER="vscsi$VSCSI_INDEX.$VSCSI_INDEX"
		QEMU_OPTS+=(
			-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
			-device virtio-scsi-pci,bus=$SCSI_BUS,addr=$SCSI_ADDR,iothread=iothread$name,id=vscsi$VSCSI_INDEX,$conarg
		)
	elif [[ "$SCSI_CONTROLLER" == "multi" ]]; then
		CONTROLLER="vscsi$VSCSI_INDEX.0"
		QEMU_OPTS+=(
			-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
			-device virtio-scsi-pci,bus=$SCSI_BUS,addr=$PCI_INDEX,iothread=iothread$name,id=vscsi$VSCSI_INDEX,$conarg
		)
	fi
	
	#		-device scsi-hd,bus=$CONTROLLER,lun=$VSCSI_INDEX,serial=$DISK_SERIAL,drive=${name}HDD,bootindex=$INDEX,needs_vpd_emulation=1024
	#	-device scsi-block,bus=$CONTROLLER,lun=$VSCSI_INDEX,drive=${name}HDD,bootindex=$INDEX
	#	-drive id=${name}HDD,if=none,$diskarg
	QEMU_OPTS+=(
		-device $devicearg,bus=$CONTROLLER,lun=$VSCSI_INDEX,drive=${name}HDD,bootindex=$INDEX
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


