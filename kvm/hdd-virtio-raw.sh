DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
RAW_OPTS="aio=native,cache.direct=on,cache=none,discard=unmap,detect-zeroes=off"

INDEX=0
function add_lvm_disk() {
	name=$1
	
	if [ -e "$DISKS_PATH/$name.raw" ]; then

		dformat=raw
		QEMU_OPTS+=( 
		-device virtio-scsi-pci,id=vscsi-$name
		-device scsi-hd,bus=vscsi-$name.0,drive=${name}HDD,bootindex=$INDEX
		-drive id=${name}HDD,if=none,file=$DISKS_PATH/$name.raw,format=$dformat,$RAW_OPTS
		)
	else 
		echo "Disk not existent $disk"
	fi
	let INDEX=INDEX+1
}

add_lvm_disk system
add_lvm_disk data
add_lvm_disk data2
