DISKS_PATH="$VM_PREFIX/$MACHINE/disks"


QCOW2_OPTS="format=qcow2,cache=directsync,aio=native,l2-cache-size=12M"
QEMU_OPTS+=( -device ahci,id=sata \
	  -device ide-drive,bus=ide.1,drive=MacHDD \
	  -device ide-drive,bus=ide.2,drive=DataHDD \
	  -drive id=MacHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS \
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS )

CLOVER_OPTS+=(  -device ide-drive,bus=ide.0,drive=CloverHDD \
	  -drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS )

