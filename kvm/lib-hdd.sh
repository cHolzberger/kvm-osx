#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh
source $SCRIPT_DIR/../kvm/lib-pci.sh
source $SCRIPT_DIR/../kvm/lib-helper.sh

DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

AIO_default="io_uring"
# must be cache=directsync for virtio-blk
# when using direct host attached storage
hdd_defaults() {
RAW_OPTS_local_default="aio=$AIO_default,cache.direct=on,cache=none,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_local_ahci="cache=none"
RAW_OPTS_local_virtio_blk_pci="aio=$AIO_default,cache.direct=on,cache=none,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_local_virtio_scsi_pci="aio=$AIO_default,cache.direct=on,cache=writethrough,discard=unmap,detect-zeroes=unmap"

RAW_OPTS_iscsi_default="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_iscsi_ahci="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_iscsi_virtio_blk_pci="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_iscsi_virtio_scsi_pci="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"

RAW_OPTS_nbd_default_="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_nbd_virtio_blk_pci="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"
RAW_OPTS_nbd_virtio_scsi_pci="aio=$AIO_default,cache.direct=on,cache=writeback,discard=unmap,detect-zeroes=unmap"

CONTROLLER_OPTS_default=""
CONTROLLER_OPTS_virtio_scsi_pci="num_queues=8"
CONTROLLER_OPTS_virtio_blk_pci="num_queues=8"

QCOW2_OPTS="cache=off,aio=threads,l2-cache-size=60M"
#QCOW2_OPTS="cache=writethrough,aio=$AIO_default,l2-cache-size=40M,discard=on,detect-zeroes=off,cache.direct=on"
QED_OPTS="cache=writethrough,aio=$AIO_default,discard=on,detect-zeroes=discard,cache.direct=on"
}

export LIBISCSI_CHAP_USERNAME 
export LIBISCSI_CHAP_PASSWORD 
export LIBISCSI_TARGET_CHAP_USERNAME 
export LIBISCSI_TARGET_CHAP_PASSWORD
	
: ${INDEX:=0}
: ${BOOTINDEX:=1}
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
	DISK=$1
	VTM=""
	if [[ "$VIRTIO_MODE" = "modern" ]]; then
		VTM=""
		VTM="disable-legacy=on,disable-modern=off,modern-pio-notify=on"
	else 
		VTM="disable-legacy=off,disable-modern=off"
	fi
	
	_VBLK="DISK_$DISK_BLOCKSIZE"
	VBLK=${!_VBLK}
	if [[ -n $VBLK ]]; then
	BS="logical_block_size=$VBLK"
	fi
	echo $VTM$BS
}

function diskarg() {
 local name="$1"
	
	hdd_defaults

	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}
	
	local kind="local"

	local DISK_TYPE_VAR="DISK_${name}_TYPE"
	local DISK_TYPE=${!DISK_TYPE_VAR}
	
	local DISK_VAR="DISK_${name}"
	local DISK=${!DISK_VAR}


	case "$DISK_TYPE" in
		"nbd") 
	  	kind="nbd"
			echo "==> Add NBD HDD" >&2 
			NBD_TARGET="$MACHINE_VAR/${name}.nbd.sock"
			;;
		"iscsi-tgt") 
		 	kind="iscsi-tgt"
			echo "==> Add ISCSI HDD" >&2 
			ISCSI_TARGET=${ISCSI_TARGET:-iscsi://127.0.0.1/iqn.2001-04.com.$(hostname).$MACHINE:$name/1}
			kind="iscsi"
			;;
		"direct-raw")
			kind="direct_raw"
			;;
		"direct-qcow2")
			kind="direct_qcow2"
			;;
	esac
	controller=RAW_OPTS_${kind}_${2:default}
	RAW_OPTS=${!controller}
	
  if [[ $kind == "nbd" ]]; then
		echo "file=nbd:unix:$NBD_TARGET,format=raw"
	elif [ $kind == "iscsi" ]; then
		qemu-img info "$ISCSI_TAGET"
		echo "file=$ISCSI_TARGET,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.raw" ]; then	
		echo "file=$DISKS_PATH/$name.raw,format=raw,$RAW_OPTS"
	elif [ -e "$DISKS_PATH/$name.qcow2" ]; then
		echo "file=$DISKS_PATH/$name.qcow2,format=qcow2,$QCOW2_OPTS"
	elif [ -e "$DISKS_PATH/$name.qed" ]; then
		echo "file=$DISKS_PATH/$name.qed,format=qed,$QED_OPTS"
	elif [ -d "$DISKS_PATH/$name.vfat" ]; then
		echo "file=fat:rw:$DISKS_PATH/$name.vfat,format=raw"
	elif [[ $kind == "direct_raw" ]]; then
		echo "file=$DISK,format=raw,$RAW_OPTS"
	elif [[ $kind == "direct_qcow2" ]] ; then
		echo "file=$DISK,format=qcow2,$QCOW2_OPTS"
	else
		echo "err"
	fi
}

function devicearg() {
	name=$1

	hdd_defaults

	DISK_SERIAL="$2"

	ISCSI_TARGET_VAR="HDD_${name}_ISCSI_TARGET"
	ISCSI_TARGET=${!ISCSI_TARGET_VAR}
	NBD_TARGET_VAR="DISK_${name}_TYPE"
  NBD_TARGET=${!NBD_TARGET_VAR}


	if [[ -n "$ISCSI_TARGET" && "$MACHINE_OS" = "win" ]]; then
		echo "scsi-block" #,serial=$DISK_SERIAL"
	elif [[ -n "$ISCSI_TARGET" && "$MACHINE_OS" = "linux" ]]; then
		echo "scsi-generic" #,serial=$DISK_SERIAL"
	else 
		echo "scsi-hd"
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
	-device virtio-blk-pci,ioeventfd=on,num-queues=8,drive=${name}HDD,scsi=off,bootindex=${BOOTINDEX},iothread=iothread$name,multifunction=on$VTM
	-drive id=${name}HDD,if=none,$diskarg
	)

	BOOTINDEX=$((BOOTINDEX+1))
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
		#add_vpci SCSI_BUS $STORE_ROOT_PORT
	#	SCSI_BUS=$STORE_ROOT_PORT
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
	#		bus=$SCSI_BUS
	#		addr=$SCSI_ADDR
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
#			bus=$SCSI_BUS
#			addr=$PCI_INDEX
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

	_DEVICE=(
       		"$devicearg"
		"bus=$CONTROLLER"
		"lun=$VSCSI_INDEX"
		"drive=${name}HDD"
		"bootindex=${BOOTINDEX}"
	)
	BOOTINDEX=$(( BOOTINDEX + 1 ))
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

	diskarg=$(diskarg "$name" ahci)
	INDEX=0
	if [ $diskarg == "err" ]; then
		echo "disk not found $name"
		return
	fi
	let INDEX=INDEX+1
	
        let AHCI_INDEX=AHCI_INDEX+1
	QEMU_OPTS+=( 
		-device ide-hd,bus=ide.$AHCI_INDEX,drive=${name}HDD,bootindex=$BOOTINDEX
		-drive id=${name}HDD,if=none,$(diskarg "$name" ahci )
	)
	BOOTINDEX=$((BOOTINDEX+1))
}

function add_ahci-raw_disk() {
	add_ahci_disk ${@}
}

function add_virtio-blk-raw_disk() {
	add_virtio_pci_disk ${@}
}

function add_virtio-scsi-raw_disk () {
	add_virtio_scsi_disk ${@}
}

function add_virtiofsd_disk() {
	name="$1"
	local DISK_TYPE_VAR="DISK_${name}_TYPE"
	local DISK_TYPE=${!DISK_TYPE_VAR}
	
	local DISK_VAR="DISK_${name}"
	local DISK=${!DISK_VAR}

	local SOCK="$MACHINE_VAR/$name.virtiofsd.sock"

	QEMU_OPTS+=( 
		-chardev socket,id=vfs-$name,path=$SOCK
	 	-device vhost-user-fs-pci,chardev=vfs-$name,tag="$DISK",queue-size=1024
	)
}
