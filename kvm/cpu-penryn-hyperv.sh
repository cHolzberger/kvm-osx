CPU=(
Penryn
kvm=off
vmware-cpuid-freq=on
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
)

# not working
#kvm=off,vendor=GenuineIntel,hv_relaxed,hv_vapic,hv_spinlocks=0x1000,+x2apic
CPUFLAGS=(
+invtsc
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$NUM_CPUS,sockets=1,cores=$NUM_CPUS,threads=1"
 -global kvm-pit.lost_tick_policy=discard
 -rtc clock=rt,base=utc,driftfix=slew
 -global ICH9-LPC.disable_s3=1
)

IFS="$OIFS"
