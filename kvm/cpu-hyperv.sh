CPU=(
host
kvm=on
vmware-cpuid-freq=on
l3-cache=on
hv_relaxed
hv_spinlocks=0x1fff
hv_vapic
hv_time
)

CPUFLAGS=(
+x2apic
+invtsc
-tsc-deadline
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
)


IFS="$OIFS"
