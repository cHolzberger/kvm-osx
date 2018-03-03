DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="format=qcow2,cache=writeback,aio=native,discard=unmap,cache.direct=on"
# AHCI Controller --- ide is ahci on q35
QEMU_OPTS+=(
-device ich9-ahci,id=ahci0,multifunction=on
-device ich9-ahci,id=ahci1,multifunction=on
)

# CLOVER BOOT
QEMU_OPTS+=(  
	-device ide-drive,bus=ide.0,drive=CloverHDD 
	-drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS
)
#DRIVES
QEMU_OPTS+=( 
	  -device ide-drive,bus=ahci0.0,drive=MacHDD 
	  -device ide-drive,bus=ahci1.0,drive=DataHDD 
	  -drive id=MacHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS 
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS 
)

#VVFAT - not working atm
# QEMU_OPTS+=(
#	  -device ide-drive,bus=ide.1,drive=EfiHDD 
#  -drive id=EfiHDD,if=none,file=fat:fat-type=16:rw:$VM_PREFIX/$MACHINE/efi/,format=vvfat,media=disk
#)


