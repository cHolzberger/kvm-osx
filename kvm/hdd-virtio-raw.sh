DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=none,discard=unmap,detect-zeroes=off"

function add_lvm_disk() {
	name=$1
	dformat=raw
	QEMU_OPTS+=( 
	-device scsi-hd,bus=vscsi.0,drive=${name}HDD,bootindex=1
	-drive id=${name}HDD,if=none,file=$DISKS_PATH/system.raw,format=$dformat,$RAW_OPTS
	)
}

QEMU_OPTS+=( 
	-device virtio-scsi-pci,id=vscsi
)
add_lvm_disk system
