CPU=(
Penryn
vmware-cpuid-freq=on
l3-cache=on
topoext=on
vendor=GenuineIntel
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
+invtsc
+pcid
+ssse3,+sse4.2
+popcnt
+aes
+avx,+avx2
+xsave,+xsaveopt,
+vmx
+bmi2,+smep,+bmi1,+fma,+movbe
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
