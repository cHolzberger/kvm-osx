CPU=(
Penryn
vmware-cpuid-freq=on
l3-cache=on
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
kvm=off
+invtsc
+x2apic
+tsc-deadline
+tsc-adjust
+avx
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -no-hpet
)

IFS="$OIFS"
