CPU=(
Penryn
vmware-cpuid-freq=on
l3-cache=on
)

#hide kvm from guest, enable tsc timer

CPUFLAGS=(
+invtsc
+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
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
