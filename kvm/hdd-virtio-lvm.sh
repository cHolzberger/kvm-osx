DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="cache=none,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off"
RAW_OPTS="aio=native,cache.direct=on,cache=writethrough"

function add_lvm_disk() {
	name=$1
	dformat=raw
	QEMU_OPTS+=( 
	-device scsi-hd,bus=vscsi.0,drive=${name}HDD,bootindex=1
	-drive id=${name}HDD,if=none,file=/dev/qemu1/office_hda,format=$dformat,$dopts
	)
}

QEMU_OPTS+=( 
	-device virtio-scsi-pci,id=vscsi
)
add_lvm_disk system

if [ -e "$DISKS_PATH/data.qcow2" ]; then
	QEMU_OPTS+=(
	 -device ahci,id=ahci0
	 -device ide-hd,bus=ahci0.0,drive=DataHDD
	 -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS 
	)
fi
