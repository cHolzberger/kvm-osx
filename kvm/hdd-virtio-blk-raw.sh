DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=none,discard=unmap,detect-zeroes=off"

function add_lvm_disk() {
	name=$1
	dformat=raw
	QEMU_OPTS+=( 
	-device virtio-blk-pci,drive=${name}HDD
	-drive id=${name}HDD,if=none,file=$DISKS_PATH/system.raw,format=$dformat,$RAW_OPTS
	)
}

add_lvm_disk system
