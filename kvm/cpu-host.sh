CPU=(
host
kvm=on
vmware-cpuid-freq=on
l3-cache=on
)

CPUFLAGS=(
+x2apic
+invtsc
-tsc-deadline
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$NUM_CPUS,sockets=$NUM_CPUS,cores=1,threads=1"
)

IFS="$OIFS"
