#!/bin/bash

function add_hyperv_flags() {
has_apicv=$(cat /sys/module/kvm_intel/parameters/enable_apicv)

CPUFLAGS+=(
hv_vendor_id=lakeuv283713
hv_relaxed=on
hv_spinlocks=0x1fff
hv_time=on
hv_reset
hv_stimer
hv_runtime
hv_crash
hv_vpindex
migratable=no
)


if [[ "$has_apicv" != "Y" ]]; then

CPUFLAGS+=(
hv_vapic
hv_synic

)		
fi

}



function hide_hypervisor() {
CPUFLAGS+=(
	kvm=off
	-hypervisor
)
}
