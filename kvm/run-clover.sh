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

OIFS="$IFS"
IFS=","
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
CMD="ionice -c 2 -n 3 $CMD"
IFS="$OIFS"

echo $CMD \
        ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
        -drive file=$EFI_ROM,if=pflash,format=raw,readonly=on \
        -drive file=$EFI_VARS,if=pflash,format=raw \


# qemu gets io priority
$CMD \
       ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
	${QEMU_EXTRA_OPTS[@]} \
	-daemonize

