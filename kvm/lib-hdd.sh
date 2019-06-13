#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh
source $SCRIPT_DIR/../kvm/lib-pci.sh
source $SCRIPT_DIR/../kvm/lib-helper.sh

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
# must be cache=directsync for virtio-blk
# when using direct host attached storage
RAW_OPTS_local_default_="aio=native,cache.direct=on,cache=none,discard=unmap"
RAW_OPTS_local_virtio_blk_pci="aio=native,cache.direct=on,cache=none,discard=unmap"
RAW_OPTS_local_virtio_scsi_pci="aio=native,cache.direct=on,cache=writethrough"

RAW_OPTS_iscsi_default_="aio=threads,cache.direct=on,cache=writeback,discard=unmap"
RAW_OPTS_iscsi_virtio_blk_pci="aio=threads,cache.direct=on,cache=writeback,discard=unmap"
RAW_OPTS_iscsi_virtio_scsi_pci="aio=threads,cache.direct=on,cache=writeback"


CONTROLLER_OPTS_default=""
CONTROLLER_OPTS_virtio_scsi_pci="num_queues=4"

QCOW2_OPTS="cache=off,aio=threads"
#QCOW2_OPTS="cache=writethrough,aio=native,l2-cache-size=40M,discard=on,detect-zeroes=off,cache.direct=on"
QED_OPTS="cache=writethrough,aio=native,discard=on,detect-zeroes=off,cache.direct=on"

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
		"-iscsi initiator-name='iqn.2019-04.de.mosaiksoftware:$HOSTNAME:$MACHINE'"
	)
	DISK_INIT=false
fi

function virtioarg() {
	VTM=""
	if [[ "$VIRTIO_MODE" = "modern" ]]; then
		VTM=""
		VTM="disable-legacy=on,disable-modern=off,modern-pio-notify=on"
	else 
		VTM="disable-legacy=off,disable-modern=off"
	fi
	echo $VTM
}

function diskarg() {
	name=$1
	
	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}
	kind="local"
	if [[ ! -z "$ISCSI_TARGET" ]]; then
		kind="iscsi"
	fi
	
	controller=RAW_OPTS_${kind}_${2:default}
	RAW_OPTS=${!controller}
	

	if [ ! -z "$ISCSI_TARGET" ]; then
		echo "file=$ISCSI_TARGET,format=raw,$RAW_OPTS"
        elif [ -e "$DISKS_PATH/$name.raw" ]; then	
		echo "file=$DISKS_PATH/$name.raw,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.qcow2" ]; then
		echo "file=$DISKS_PATH/$name.qcow2,format=qcow2,$QCOW2_OPTS"
	elif [ -e "$DISKS_PATH/$name.qed" ]; then
		echo "file=$DISKS_PATH/$name.qed,format=qed,$QED_OPTS"
	
	else
		echo "err"
	fi
}

function devicearg() {
	name=$1
	DISK_SERIAL="$2"
	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}

	if [[ ! -z "$ISCSI_TARGET" && "$MACHINE_OS" = "win" ]]; then
		echo "scsi-block" #,serial=$DISK_SERIAL"
	elif [[ ! -z "$ISCSI_TARGET" && "$MACHINE_OS" = "linux" ]]; then
		echo "scsi-generic" #,serial=$DISK_SERIAL"
	else 
		echo "scsi-hd"
		#echo ""
	fi
}

# Use case: passathrough host device as pcie disk
# sometimes giving errors oon windows
: ${VBLK_INDEX:=0}
function add_virtio_pci_disk() {
	name=$1

	diskarg=$(diskarg $name virtio_blk_pci)
	virtarg=$(virtioarg $name virtio_blk_pci)

	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	

	QEMU_OPTS+=( 
	-object iothread,id=iothread$name,poll-max-ns=20,poll-grow=4,poll-shrink=0
	-device virtio-blk-pci,ioeventfd=on,num-queues=8,drive=${name}HDD,scsi=off,bootindex=$INDEX,iothread=iothread$name,multifunction=on$VTM
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
	virtarg=$(virtioarg $name virtio_scsi_pci)
	
	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	let PCI_INDEX=$VSCSI_INDEX+1


	if [[ "x$VSCSI_INDEX" == "x0" ]] && [[ "$SCSI_CONTROLLER" != "multi" ]]; then
		CONTROLLER="vscsi$VSCSI_INDEX.$VSCSI_INDEX"
		add_vpci SCSI_BUS $STORE_ROOT_PORT
		SCSI_ADDR="0x0"
		echo "[VIRTIO[$VIRTIO_MODE]]Creating vrtio-scsi-pci - $SCSI_CONTROLLER (vscsi$VSCSI_INDEX) BUS: $SCSI_BUS ADDR: $SCSI_ADDR"

		O=(
			iothread
			id=iothread$name
			#poll-max-ns=20
			#poll-grow=4
			#poll-shrink=0
		)

		D=(
			virtio-scsi-pci
			bus=$SCSI_BUS
			addr=$SCSI_ADDR
			iothread=iothread$name
			num_queues=4
			id=vscsi$VSCSI_INDEX
			$conarg
			$virtarg
		)
		QEMU_OPTS+=(
			-object $( IFS=",$IFS"; printf "%s" "${O[*]}" )
			-device $( IFS=",$IFS"; printf "%s" "${D[*]}" )
		)	

	elif [[ "$SCSI_CONTROLLER" == "multi" ]]; then
		CONTROLLER="vscsi$VSCSI_INDEX.0"
 		add_vpci SCSI_BUS $STORE_ROOT_PORT
		SCSI_ADDR="0x0"
	
		echo "[VIRTIO[$VIRTIO_MODE]]Creating vrtio-scsi-pci - $SCSI_CONTROLLER (vscsi$VSCSI_INDEX) BUS: $SCSI_BUS ADDR: $SCSI_ADDR"
		O=(
			iothread
			id=iothread$name
			poll-max-ns=20
			poll-grow=4
			poll-shrink=0
		)
		D=(
			virtio-scsi-pci
			bus=$SCSI_BUS
			addr=$PCI_INDEX
			iothread=iothread$name
			id=vscsi$VSCSI_INDEX
			$conarg
			$virtarg
		)
		QEMU_OPTS+=(
			-object $( IFS=",$IFS"; printf "%s" "${O[*]}" )
			-device $( IFS=",$IFS"; printf "%s" "${D[*]}" )
		)
	fi

	#		-device scsi-hd,bus=$CONTROLLER,lun=$VSCSI_INDEX,serial=$DISK_SERIAL,drive=${name}HDD,bootindex=$INDEX,needs_vpd_emulation=1024
	#	-device scsi-block,bus=$CONTROLLER,lun=$VSCSI_INDEX,drive=${name}HDD,bootindex=$INDEX
	#	-drive id=${name}HDD,if=none,$diskarg
	_DEVICE=(
       		"$devicearg"
		"bus=$CONTROLLER"
		"lun=$VSCSI_INDEX"
		"drive=${name}HDD"
		"bootindex=$INDEX"
	)

	_DRIVE=(
		"id=${name}HDD"
		"if=none"
		"$diskarg"
	)
	DEVICE=$( IFS=",$IFS"; printf '%s' "${_DEVICE[*]}" )
	DRIVE=$( IFS=",$IFS"; printf '%s' "${_DRIVE[*]}" )

	echo -e "DRIVE:\t $DRIVE"
	echo -e "DEVICE:\t $DEVICE"

	QEMU_OPTS+=(
		-drive $DRIVE
		-device $DEVICE
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
	INDEX=0
	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	
	if [[ $AHCI_INDEX == "0" ]]; then
		QEMU_OPTS+=(
			-device ich9-ahci,id=ahci0,addr=4,bus=pcie.0
		)
	fi

	QEMU_OPTS+=( 
#		-device ich9-ahci,id=ahci$INDEX,addr=4,bus=pcie.0
		-device ide-hd,bus=ahci$INDEX.$AHCI_INDEX,drive=${name}HDD,bootindex=$AHCI_INDEX
		-drive id=${name}HDD,if=none,$(diskarg $name)
	)
        let INDEX=INDEX+1
        let AHCI_INDEX=AHCI_INDEX+1
}


