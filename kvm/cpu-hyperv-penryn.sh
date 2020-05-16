CPU=(
Penryn
kvm=on
vmware-cpuid-freq=on
l3-cache=on
#migratable=off
+invtsc
monitor=on
)

# not working
#kvm=off,vendor=GenuineIntel,hv_relaxed,hv_vapic,hv_spinlocks=0x1000,+x2apic
CPUFLAGS=(
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -rtc clock=rt,base=utc,driftfix=slew
 -no-hpet
)

IFS="$OIFS"
