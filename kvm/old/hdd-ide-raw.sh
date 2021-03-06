DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="cache=none,aio=native,l2-cache-size=40M,discard=unmap,detect-zeroes=off"
RAW_OPTS="aio=native,cache.direct=on,cache=none,discard=unmap"

INDEX=0
function add_lvm_disk() {
	name=$1
	dformat=${2:-"raw"}

	diskpath=$DISKS_PATH/$name.$dformat

	if [ -e $diskpath ]; then
	QEMU_OPTS+=( 
	-drive id=${name}HDD,if=ide,file=$diskpath,format=$dformat,$RAW_OPTS
	)
	let INDEX=INDEX+1
	else
		echo "Can't find: $diskpath"
	fi
}

QEMU_OPTS+=( 
)
add_lvm_disk system
add_lvm_disk data
add_lvm_disk data qcow2
