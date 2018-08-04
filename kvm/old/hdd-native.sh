DISKS_PATH="$VM_PREFIX/$MACHINE/disks/$HDD_DISKSET"

QCOW2_OPTS="format=qcow2,cache=writethrough,cache.direct=on,aio=native,l2-cache-size=40M"
QEMU_OPTS+=( 
	-device ahci,id=sata 
	-device ide-drive,bus=sata.1,drive=SysHDD 
	-drive id=SysHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS 
)

if [ -e "$DISKS_PATH/data.qcow2" ]; then
	QEMU_OPTS+=(
	  -device ide-drive,bus=ide.3,drive=DataHDD 
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS 
	)
fi
