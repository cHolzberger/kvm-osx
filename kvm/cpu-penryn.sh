CPU=(
Penryn
kvm=on
vmware-cpuid-freq=on
l3-cache=on
)

# not working
#kvm=off,vendor=GenuineIntel,hv_relaxed,hv_vapic,hv_spinlocks=0x1000,+x2apic
CPUFLAGS=(
+invtsc
+aes
+apic
+xsave
+avx 
+xsaveopt
+smep
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -global kvm-pit.lost_tick_policy=discard
 -rtc clock=rt,base=utc,driftfix=slew
 -global ICH9-LPC.disable_s3=1
)

IFS="$OIFS"
