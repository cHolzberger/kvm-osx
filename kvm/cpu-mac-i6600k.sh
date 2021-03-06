CPU=(
Penryn
kvm=on
vmware-cpuid-freq=on
l3-cache=on
topoext=on
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
# nested virt
+vmx
+rdtscp
# stuff
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
 -no-hpet
)

IFS="$OIFS"
