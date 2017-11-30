DISKS_PATH="$VM_PREFIX/$MACHINE/disks"

QEMU_OPTS+=( 
        -bios efi/ovmf.$EFI_ROM.fd
)
if [ ! -e "efi/ovmf.$EFI_ROM.efi" ]; then
	echo "EFI ROM $EFI_ROM does not exist"
	exit -1
fi

