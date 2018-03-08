DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="cache=directsync,aio=native,l2-cache-size=40M,discard=off,detect-zeroes=off"

function adddisk() {
	name=$1
	
	bname=$DISKS_PATH/${name}
	dname=""
	dformat=""
	dopts=""
	echo $bname
	if [ -e "$(realpath $bname.raw)" ]; then
		dname=$bname.raw
		dformat=raw
		dopts="aio=native,cache.direct=on"
		echo "[DISK] Using $danme as raw"
	elif [ -e "$(realpath $bname.qcow2)" ]; then
		dname=$bname.qcow2
		dformat=qcow2
		dopts="$QCOW2_OPTS"
		echo "[DISK] Using $danme as raw"
	fi

	QEMU_OPTS+=( 
	-object iothread,id=iothread0
	-device virtio-blk-pci,iothread=iothread0,drive=${name}HDD,scsi=off,write-cache=on,bootindex=0
	-drive id=${name}HDD,if=none,file=$dname,format=$dformat,$dopts
	)
}

QEMU_OPTS+=( 
	-device ahci,id=sata
)
adddisk system

if [ -e "$DISKS_PATH/data.qcow2" ]; then
	QEMU_OPTS+=(
	 -device ide-drive,bus=sata.0,drive=DataHDD
	 -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS 
	)
fi
