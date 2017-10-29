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
OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$NUM_CPUS,sockets=1,cores=$NUM_CPUS,threads=1"
)

IFS="$OIFS"
