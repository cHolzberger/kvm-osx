DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

QEMU_OPTS+=( 
        -drive file=efi/ovmf.$OVM_VERS.efi,if=pflash,format=raw,unit=0,readonly=on 
	-drive file=$DISKS_PATH/ovmf.$OVM_VERS.vars,if=pflash,format=raw,unit=1 
)

