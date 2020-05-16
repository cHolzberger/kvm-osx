CPU=(
Penryn
vmware-cpuid-freq=on
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
hv_time=on
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
kvm=off
+invtsc
+x2apic
+tsc-deadline
+tsc-adjust
+avx
+avx2
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
