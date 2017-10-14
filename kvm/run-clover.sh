CMD="qemu-system-x86_64"

EFI_ROM=efi/ovmf.$OVM_VERS.efi
EFI_VARS=efi/ovmf.$OVM_VERS.vars

if [ ! -e "$EFI_ROM" ]; then
	echo "EFI ROM $EFI_ROM does not exist"
	exit -1
fi

if [ ! -e "$EFI_VARS" ]; then
	echo "EFI VARS $EFI_VARS does not exist"
	exit -1
fi

if [ "x$USE_CPUS" != "x" ]; then
	echo "Using CPUS: $USE_CPUS"
	CMD="$CMD"
fi
echo $CMD \
        -vga none \
        -nographic \
        ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
        -drive file=$EFI_ROM,if=pflash,format=raw,readonly=on \
        -drive file=$EFI_VARS,if=pflash,format=raw \


$CMD \
        -vga none \
        -nographic \
        ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
        -drive file=efi/ovmf.$OVM_VERS.efi,if=pflash,format=raw,unit=0,readonly=on \
        -drive file=efi/ovmf.$OVM_VERS.vars,if=pflash,format=raw,unit=1 \

