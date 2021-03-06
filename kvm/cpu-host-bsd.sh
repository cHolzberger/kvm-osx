CPU=(
host
kvm=on
l3-cache=on
)

CPUFLAGS=(
+apic
+aes
+sse2
+sse4_1
+sse4_2
#-xsave
#-tsc-deadline
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -global kvm-pit.lost_tick_policy=discard
 --no-acpi
)

IFS="$OIFS"
