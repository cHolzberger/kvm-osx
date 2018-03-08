DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="cache=writeback,cache.direct=on,aio=native,l2-cache-size=40M,discard=unmap,detect-zeroes=off"
RAW_OPTS="aio=native,cache.direct=on,cache=writeback,discard=unmap"

INDEX=1
function add_lvm_disk() {
	name=$1
	dformat=${2:-"raw"}

	diskpath=$DISKS_PATH/$name.$dformat

	if [ -e $diskpath ]; then
	QEMU_OPTS+=( 
	-device ide-hd,bus=ahci0.$INDEX,drive=${name}HDD,bootindex=$INDEX
	-drive id=${name}HDD,if=none,file=$diskpath,format=$dformat,$RAW_OPTS
	)
	let INDEX=INDEX+1
	else
		echo "Can't find: $diskpath"
	fi
}

QEMU_OPTS+=( 
	 -device ahci,id=ahci0
)

# CLOVER BOOT
if [ -e $DISKS_PATH/clover.qcow2 ]; then
QEMU_OPTS+=(
        -device ide-drive,bus=ahci0.0,drive=CloverHDD,bootindex=0
        -drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS
)
elif [ -e $DISKS_PATH/clover.raw ]; then
QEMU_OPTS+=(
        -device ide-drive,bus=ahci0.0,drive=CloverHDD,bootindex=0
        -drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.raw,format=raw,$RAW_OPTS
)

fi

add_lvm_disk system
add_lvm_disk data
add_lvm_disk data qcow2
