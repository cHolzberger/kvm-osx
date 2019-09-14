#!/bin/bash

function has_flag() {
	FLAG="$1"
	NOFLAG="$2"
	lscpu | grep "Flags:" | grep " $FLAG " > /dev/null
	if [[ "$?" = "0" ]]; then
		echo "+$FLAG"
		echo "[CPU] Adding CPU Flag: $FLAG" >&2
	else 
		echo "[CPU] $FLAG is missing adding $NOFLAG instead" >&2
		echo $NOFLAG
	fi
}

function add_hyperv_flags() {

	CPUFLAGS+=(
		hv_relaxed=on
		hv_spinlocks=0x8191
		hv_time=on
		hv_stimer=on
		#hv_synic=on
		hv_vpindex=on
		#+kvm_pv_unhalt
		#hv_reset
		#hv_runtime
		#hv_crash
		#migratable=no
		$(has_flag x2apic "hv_vapic=on")
	)

	add_x86_flags
}

function add_kvm_flags() {
	CPUFLAGS+=(
		+kvm-asyncpf
       		+kvm-hint-dedicated
  		+kvm-mmu 
		+kvm-nopiodelay 
		+kvm-pv-eoi 
		+kvm-pv-ipi 
		+kvm-pv-tlb-flush
  		+kvm-pv-unhalt 
		+kvm-steal-time 
		+kvmclock 
		+kvmclock-stable-bit
	)
	add_apic_flags
	add_x86_flags

}

function add_x86_flags() {
	CPUFLAGS+=(
		$(has_flag ssse3)
		$(has_flag sse4.1)
		$(has_flag sse4.2)
		$(has_flag avx)
		$(has_flag avx2)
		$(has_flag aes)
		$(has_flag vmx)
		$(has_flag pcid)
		$(has_flag pdpe1gb)
		+lahf_lm
		+hv-tlbflush
		#enforce
		spec-ctrl
		#$(has_flag ssbd)
	)
}

function add_apic_flags() {

	has_apicv=$(cat /sys/module/kvm_intel/parameters/enable_apicv)
	if [[ "$has_apicv" != "Y" ]]; then
		CPUFLAGS+=(
			$(has_flag x2apic "hv_vapic=on")
		)

	else
		CPUFLAGS+=(
			"apicv"
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
