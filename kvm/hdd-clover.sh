DISKS_PATH="$VM_PREFIX/$MACHINE/disks"


QCOW2_OPTS="format=qcow2,cache=writethrough,aio=native,l2-cache-size=40M,cache.direct=on"
QEMU_OPTS+=( -device ahci,id=sata \
	  -device ide-drive,bus=ide.1,drive=MacHDD \
	  -device ide-drive,bus=ide.2,drive=DataHDD \
	  -drive id=MacHDD,if=none,file=$DISKS_PATH/system.qcow2,$QCOW2_OPTS \
	  -drive id=DataHDD,if=none,file=$DISKS_PATH/data.qcow2,$QCOW2_OPTS )

#QEMU_OPTS+=(
#-drive file=$DISKS_PATH/nvme.qcow2,if=none,id=lightnvme 
#-device nvme,drive=lightnvme,serial=deadbeef
#)

CLOVER_OPTS+=(  -device ide-drive,bus=ide.0,drive=CloverHDD 
	-drive id=CloverHDD,if=none,index=0,file=$DISKS_PATH/clover.qcow2,$QCOW2_OPTS
        -drive file=efi/ovmf.$OVM_VERS.efi,if=pflash,format=raw,unit=0,readonly=on 
	-drive file=$DISKS_PATH/ovmf.$OVM_VERS.vars,if=pflash,format=raw,unit=1 
	-device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" )


