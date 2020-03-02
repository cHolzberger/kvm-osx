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
 -global ICH9-LPC.disable_s3=1
 -no-hpet
)

IFS="$OIFS"
