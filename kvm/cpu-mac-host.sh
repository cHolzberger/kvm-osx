CPU=(
host
kvm=on
#vmx=off
hypervisor=on 
vmware-cpuid-freq=on
l3-cache=on
#host-cache-info=off
topoext=on
vendor=GenuineIntel
migratable=no
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
#needed by macos
+bmi1
+bmi2
+invtsc
+aes
+avx
+fma
# 
-erms
+pcid
+ssse3
+sse4_1
+sse4.2
+popcnt
+xsave
+xsaveopt
+vmx
+movbe
+x2apic
+misalignsse,+movbe,+osvw,+pclmuldq,+pdpe1gb,+rdrand,+rdseed,+rdtscp,+sha-ni,+smap,+smep,+svm,+vme,+xgetbv1,+xsave,+xsavec,+clwb,+umip,+topoext,+perfctr-core,+wbnoinvd
+avx2
+fma
check

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
