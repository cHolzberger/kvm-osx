#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-cfh.sh

#topoext=on
CPU=(
host
kvm=off
l3-cache=on
monitor=on
)

CPUFLAGS=(
)

add_hyperv_nested_flags
hide_hypervisor

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]},kvm=on,hv_vendor_id=intel"
 -smp "$CPU_SMP"
 -no-hpet
 -global kvm-pit.lost_tick_policy=discard
 -smbios '"type=0,vendor=LENOVO,version=FBKTB4AUS,date=07/01/2015,release=1.180"'
 -smbios '"type=1,manufacturer=LENOVO,product=30AH001GPB,version=ThinkStation P300,serial=System Serial,uuid='$UUID',sku=LENOVO_MT_30AH,family=P3"'
)

IFS="$OIFS"
