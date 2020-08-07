source $SCRIPT_DIR/../kvm/lib-cfh.sh

CPU=(
qemu64
l3-cache=on
)

#hide kvm from guest, enable tsc timer
add_kvm_flags
CPUFLAGS=(
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
)

IFS="$OIFS"
