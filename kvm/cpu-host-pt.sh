CPU=(
host
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
hv_time=on
)

CPUFLAGS=(
vmx=on
+invtsc
+x2apic
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -no-hpet
 -global kvm-pit.lost_tick_policy=discard
)

IFS="$OIFS"
