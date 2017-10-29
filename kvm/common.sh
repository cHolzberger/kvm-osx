CPU=(
Penryn
kvm=on
vmware-cpuid-freq=on
l3-cache=on
)

CPUFLAGS=(
+x2apic
+invtsc
-tsc-deadline
+aes
+apic
+xsave
+avx 
+xsaveopt
+smep
)

#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
OIFS="$IFS"
IFS=","
#-cpu Penryn,kvm=off,vendor=GenuineIntel,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=blah  \
#-cpu Penryn,kvm=on,vendor=GenuineIntel,vmware-cpuid-freq=on,+invtsc,"${CPUFLAGS[*]}" 
# -smp "${NUM_CPUS},sockets=${NUM_CPUS},cores=1,threads=1"
# -m 4G,slots=4,maxmem=$MEM 
QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -machine pc-q35-2.10 
 -name "$MACHINE"
 -realtime mlock=off
 -rtc base=utc,driftfix=slew 
 -global kvm-pit.lost_tick_policy=discard 
 -smbios type=2
 -global ICH9_LPC.disable_s3=on
 -global ICH9_LPC.disable_s4=on
 -global kvm-pit.lost_tick_policy=discard
 -usbdevice tablet
 )

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()

IFS="$OIFS"
