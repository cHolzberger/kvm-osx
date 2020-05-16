CPU=(
IvyBridge
migratable=off
kvm=off
vmware-cpuid-freq=on
l3-cache=on
)

CPUFLAGS=(
+invtsc
+aes
+apic
+xsave
+avx
+xsaveopt
+smep
-tsc-deadline
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
