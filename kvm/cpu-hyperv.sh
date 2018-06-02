CPU=(
host
kvm=off
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
hv_time=on
)

CPUFLAGS=(
+x2apic
+invtsc
)


OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -global kvm-pit.lost_tick_policy=discard
 -global ICH9-LPC.disable_s3=1
)

IFS="$OIFS"
