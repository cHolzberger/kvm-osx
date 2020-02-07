CPU=(
host
kvm=on
vmware-cpuid-freq=on
l3-cache=on
host-cache-info=off
#topoext=on
vendor=GenuineIntel
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
-erms
+invtsc
+pcid
+ssse3
+sse4.2
+popcnt
+aes
+avx
+avx2
+xsave
+xsaveopt,
+vmx
+bmi2,+smep,+bmi1,+fma,+movbe
+x2apic
+misalignsse,+movbe,+osvw,+pclmuldq,+pdpe1gb,+rdrand,+rdseed,+rdtscp,+sha-ni,+smap,+smep,+svm,+vme,+xgetbv1,+xsave,+xsavec,+clwb,+umip,+topoext,+perfctr-core,+wbnoinvd
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
