CPU=(
host
kvm=on
vmware-cpuid-freq=on
l3-cache=on
)

CPUFLAGS=(
+apic
-xsave
-tsc-deadline
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -global kvm-pit.lost_tick_policy=discard
 -global ICH9-LPC.disable_s3=1
 --no-acpi
)

IFS="$OIFS"
