CPU=(
Penryn
vmware-cpuid-freq=on
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
hv_time=on
)

#kvm=off
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
 -smp "$NUM_CPUS,sockets=$NUM_CPUS,cores=1,threads=1"
 -global kvm-pit.lost_tick_policy=discard
 -rtc clock=rt,base=utc,driftfix=slew
 -global ICH9-LPC.disable_s3=1
)

IFS="$OIFS"
