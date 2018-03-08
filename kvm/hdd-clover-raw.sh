DISKS_PATH="$VM_PREFIX/$MACHINE/disks"
QCOW2_OPTS="format=qcow2,cache=writeback,aio=native,discard=unmap,cache.direct=on"
RAW_OPTS="format=raw,aio=native,cache.direct=on,cache=none,discard=unmap"

# AHCI Controller --- ide is ahci on q35
QEMU_OPTS+=(
-device ich9-ahci,id=ahci0,multifunction=on
-device ich9-ahci,id=ahci1,multifunction=on
)

# CLOVER BOOT
QEMU_OPTS+=(  
	-device ide-drive,bus=ide.0,bootindex=0,drive=CloverHDD 
	-drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.raw,$RAW_OPTS
)
#DRIVES
QEMU_OPTS+=( 
	  -device ide-drive,bus=ahci0.0,drive=MacHDD 
	  -device ide-drive,bus=ahci1.0,drive=DataHDD 
	  -drive id=MacHDD,index=2,if=none,file=$DISKS_PATH/system.raw,$RAW_OPTS 
	  -drive id=DataHDD,index=3,if=none,file=$DISKS_PATH/data.raw,$RAW_OPTS 
)

#VVFAT - not working atm
# QEMU_OPTS+=(
#	  -device ide-drive,bus=ide.1,drive=EfiHDD 
#  -drive id=EfiHDD,if=none,file=fat:fat-type=16:rw:$VM_PREFIX/$MACHINE/efi/,format=vvfat,media=disk
#)


