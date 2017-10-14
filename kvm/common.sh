CPU=(
host
kvm=on
vmware-cpuid-freq=on
)

CPUFLAGS=(
+invtsc
-tsc-deadline
)

#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
OIFS="$IFS"
IFS=","
#-cpu Penryn,kvm=off,vendor=GenuineIntel,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=blah  \
#-cpu Penryn,kvm=on,vendor=GenuineIntel,vmware-cpuid-freq=on,+invtsc,"${CPUFLAGS[*]}" 
# -smp "${NUM_CPUS},sockets=${NUM_CPUS},cores=1,threads=1"
# -m 4G,slots=4,maxmem=$MEM 
QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "8,sockets=8,cores=1,threads=1"
 -machine pc-q35-2.9 
 -name "$MACHINE"
 -realtime mlock=on
 -rtc base=utc,driftfix=slew 
 -global kvm-pit.lost_tick_policy=discard 
 -smbios type=2
 -chardev socket,id=mon0,host=localhost,port=4444,server,nowait
 -mon chardev=mon0,mode=control,pretty=on
 -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
 -global ICH9_LPC.disable_s3=on
 -global ICH9_LPC.disable_s4=on
 )
CLOVER_OPTS=()
BIOS_OPTS=()

IFS="$OIFS"
