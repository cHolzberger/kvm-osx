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
)
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -global ICH9-LPC.disable_s3=1
 -no-hpet
)

IFS="$OIFS"
