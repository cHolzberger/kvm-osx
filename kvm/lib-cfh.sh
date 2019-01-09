#!/bin/bash

function add_hyperv_flags() {
has_apicv=$(cat /sys/module/kvm_intel/parameters/enable_apicv)

CPUFLAGS+=(
hv_vendor_id=lakeuv283713
hv_relaxed=on
hv_spinlocks=0x8191
hv_time=on
hv_stimer=on
hv_synic=on
hv_vpindex=on
vmx=on
)

#hv_reset
#hv_runtime
#hv_crash
#migratable=no


if [[ "$has_apicv" != "Y" ]]; then
	CPUFLAGS+=(
	+x2apic
	)
else
	CPUFLAGS+=(
		hv_vapic=on
	)
fi
}


function hide_hypervisor() {
CPUFLAGS+=(
	kvm=off
	-hypervisor
)
}
