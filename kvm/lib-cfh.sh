#!/bin/bash

#see https://unix.stackexchange.com/questions/43539/what-do-the-flags-in-proc-cpuinfo-mean
function list_flags() {
	 lscpu | grep "Flags:" | sed -e 's/ /\n/g' | grep -v "Flags:"
}

function has_flag() {
	FLAG="$1"
	NOFLAG="$2"
	ADD="${3:-""}"
	list_flags | grep '^'$FLAG'$' > /dev/null
	if [[ "$?" = "0" ]]; then
		[[ -n $ADD ]] && FLAG="$FLAG,$ADD" 
		echo "+$FLAG"
		echo "[CPU] Adding CPU Flag: $FLAG" >&2
	else 
		echo "[CPU] $FLAG is missing adding $NOFLAG instead" >&2
		echo $NOFLAG
	fi
}


function add_hyperv_nested_flags() {
	add_hyperv_flags

	CPUFLAGS+=(
	vmx
	$(has_flag dca)
	$(has_flag xtpr)
	$(has_flag tm2)
	$(has_flag ds_cpl)
	$(has_flag pbe)
	$(has_flag tm)
	$(has_flag ht)
	$(has_flag ss)
	$(has_flag acpi)
	$(has_flag vme)
	)
}
# see https://github.com/qemu/qemu/blob/master/docs/hyperv.txt
function add_hyperv_flags() {
	CPUFLAGS+=(
#		migrateable=no
		hv_relaxed=on
		hv_spinlocks=0x8191
		hv_time=on
		hv_tlbflush
		hv_ipi
    hv_frequencies
		hv_reenlightenment
		hv_reset
		hv_vpindex=on
		hv_synic=on
		hv_stimer=on
	  hv_stimer_direct
	  x-hv-synic-kvm-only
		hv_vapic
		hv_frequencies 
		hv_evmcs
)
# to check:
#		hv_vapic -> watch it makes problems on cpus not having x2apic
#	add_apic_flags
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
		migratable=no
		$(has_flag sse)
		$(has_flag sse2)
		$(has_flag spec-ctrl)
		$(has_flag pcid)
		$(has_flag ssse3)
		$(has_flag sse4_1)
		$(has_flag sse4_2)
		$(has_flag avx)
		$(has_flag avx2)
		$(has_flag aes)
		$(has_flag pcid)
		$(has_flag pdpe1gb)
		$(has_flag popcnt)
		+lahf_lm
		$(has_flag qlahf_lm)
		#$(has_flag ssbd)
	)
}

function add_apic_flags() {
	has_apicv=$(cat /sys/module/kvm_intel/parameters/enable_apicv)
	if [[ "$has_apicv" == "Y" ]]; then
		CPUFLAGS+=(
			"apicv"
		)

	else
		CPUFLAGS+=(
			hv_vapic=on
#			"apicv"
		)
	fi
}

function expose_hypervisor() {
CPUFLAGS+=(
	kvm=on
	hypervisor=on
)
}

function hide_hypervisor() {
#	hv_vendor_id=Nvidia43FIX
CPUFLAGS+=(
	kvm=off
	hv_vendor_id=lakeuv283713
	-hypervisor
)
}
