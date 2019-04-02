#!/bin/bash

function has_flag() {
	FLAG=$1
	lscpu | grep "Flags:" | grep " $FLAG " > /dev/null
	if [[ "$?" = "0" ]]; then
		echo "+$FLAG"
	fi
}

function add_hyperv_flags() {
has_apicv=$(cat /sys/module/kvm_intel/parameters/enable_apicv)

CPUFLAGS+=(
hv_relaxed=on
hv_spinlocks=0x8191
hv_time=on
hv_stimer=on
#hv_synic=on
hv_vpindex=on
#+kvm_pv_unhalt
+kvm_pv_eoi
+lahf_lm
+hv-tlbflush
$(has_flag vmx)
#enforce
)

#hv_reset
#hv_runtime
#hv_crash
#migratable=no


if [[ "$has_apicv" != "Y" ]]; then
	CPUFLAGS+=(
		$(has_flag x2apic)
	)

else
	CPUFLAGS+=(
		hv_vapic=on
	)
fi
}


function hide_hypervisor() {
#	hv_vendor_id=Nvidia43FIX
CPUFLAGS+=(
	kvm=off
	hv_vendor_id=lakeuv283713
	-hypervisor
)
}
