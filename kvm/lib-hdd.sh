DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=directsync"

INDEX=0

function add_virtio_pci_disk() {
	name=$1
	dformat=raw
	QEMU_OPTS+=( 
	-object iothread,id=iothread$name
	-device virtio-blk-pci,drive=${name}HDD,scsi=off,config-wce=off,bootindex=0,iothread=iothread$name
	-drive id=${name}HDD,if=none,file=$DISKS_PATH/$name.raw,format=$dformat,$RAW_OPTS
	)
        let INDEX=INDEX+1
	echo "Adding Virtio-PCI Disk: $name"
}

function add_virtio_scsi_disk() {
        name=$1

        if [ -e "$DISKS_PATH/$name.raw" ]; then
                echo ""
                dformat=raw
                QEMU_OPTS+=(
                -device virtio-scsi-pci,id=vscsi-$name
                -device scsi-hd,bus=vscsi-$name.0,drive=${name}HDD,bootindex=$INDEX
                -drive id=${name}HDD,if=none,file=$DISKS_PATH/$name.raw,format=$dformat,$RAW_OPTS
                )
        else
                echo "Disk not existent $name"
        fi
	echo "Adding VirtioSCSI Disk: $name"
        let INDEX=INDEX+1
}

