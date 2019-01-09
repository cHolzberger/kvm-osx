#!/bin/bash

source $SCRIPT_DIR/../kvm/lib-cfh.sh

CPU=(
host
topoext=on
kvm=off
l3-cache=on
)

CPUFLAGS=(
+invtsc
)

add_hyperv_flags
hide_hypervisor

OIFS="$IFS"
IFS=","
#
QEMU_OPTS+=(
 -cpu "${CPU[*]}","${CPUFLAGS[*]}"
 -smp "$CPU_SMP"
 -no-hpet
 -global kvm-pit.lost_tick_policy=discard
 -global ICH9-LPC.disable_s3=1
 -smbios '"type=0,vendor=LENOVO,version=FBKTB4AUS,date=07/01/2015,release=1.180"'
 -smbios '"type=1,manufacturer=LENOVO,product=30AH001GPB,version=ThinkStation P300,serial=System Serial,uuid='$UUID',sku=LENOVO_MT_30AH,family=P3"'
)

IFS="$OIFS"
