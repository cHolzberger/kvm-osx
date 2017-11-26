DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

# AHCI Controller
QEMU_OPTS+=(
-device ich9-ahci,id=ahci0 
)

# CLOVER BOOT
QEMU_OPTS+=(  
	-device ide-drive,bus=ide.0,drive=CloverHDD 
	-drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS
	-device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" 
)
#DRIVES
QCOW2_OPTS="format=qcow2,cache=writethrough,aio=native,l2-cache-size=40M,cache.direct=on,discard=unmap"
QEMU_OPTS+=( 
	  -device ide-drive,bus=ahci0.1,drive=MacHDD 
	  -device ide-drive,bus=ahci0.2,drive=DataHDD 
	  -drive id=MacHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS 
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS 
)




