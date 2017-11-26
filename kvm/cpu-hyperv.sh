CPU=(
host
kvm=on
l3-cache=on
hv_relaxed=on
hv_spinlocks=0x1fff
hv_vapic=on
hv_time=on
)

CPUFLAGS=(
)

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -no-hpet
 -global kvm-pit.lost_tick_policy=discard
 -rtc clock=rt,base=utc
 -global ICH9-LPC.disable_s3=1
)

IFS="$OIFS"
