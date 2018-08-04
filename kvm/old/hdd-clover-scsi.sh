DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

# CLOVER BOOT
QEMU_OPTS+=(  
	-device ide-drive,bus=ide.0,drive=CloverHDD 
	-drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS
	-device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" 
)
#DRIVES
QCOW2_OPTS="format=qcow2,cache=writeback,aio=native,l2-cache-size=40M,cache.direct=on"
RAW_OPTS="format=raw,cache=writeback,aio=native,cache.direct=on"
QEMU_OPTS+=( 
	-device ich9-ahci,id=ahci0 
	  -device ide-drive,bus=ahci0.1,drive=MacHDD 
	  -device nvme,logical_block_size=4096,physical_block_size=4096,serial=foo,drive=DataHDD 
	  -drive id=MacHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS 
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/nvme.raw,$RAW_OPTS 
)




