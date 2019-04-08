DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

if [[ ! -x $DISKS_PATH/ovmf.$EFI_VARS.vars ]]; then
	cp "$SCRIPT_DIR/../efi/ovmf.$EFI_VARS.vars"  "$DISKS_PATH/ovmf.$EFI_VARS.vars"
fi

QEMU_OPTS+=(
        -drive file=$SCRIPT_DIR/../efi/ovmf.$EFI_ROM.efi,if=pflash,format=raw,unit=0,readonly=on 
	-drive file=$DISKS_PATH/ovmf.$EFI_VARS.vars,if=pflash,format=raw,unit=1 
)

if [ ! -e "efi/ovmf.$EFI_ROM.efi" ]; then
	echo "EFI ROM $EFI_ROM does not exist"
	exit -1
fi

if [ ! -e "$DISKS_PATH/ovmf.$EFI_VARS.vars" ]; then
	echo "EFI VARS $EFI_VARS does not exist"
	exit -1
fi

