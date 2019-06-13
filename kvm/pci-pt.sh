#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh
PT_ADDR=0x0
[[ ! -z "$PT1_MODE" ]] && add_vpci PT_BUS $PT_ROOT_PORT && add_${PT1_MODE}_dev "$PT1_PCI" "$PT_BUS" "$PT_ADDR"
[[ ! -z "$PT2_MODE" ]] && add_vpci PT_BUS $PT_ROOT_PORT && add_${PT2_MODE}_dev "$PT2_PCI" "$PT_BUS" "$PT_ADDR"
[[ ! -z "$PT3_MODE" ]] && add_vpci PT_BUS $PT_ROOT_PORT && add_${PT3_MODE}_dev "$PT3_PCI" "$PT_BUS" "$PT_ADDR"
[[ ! -z "$PT4_MODE" ]] && add_vpci PT_BUS $PT_ROOT_PORT && add_${PT4_MODE}_dev "$PT4_PCI" "$PT_BUS" "$PT_ADDR"
[[ ! -z "$PT5_MODE" ]] && add_vpci PT_BUS $PT_ROOT_PORT && add_${PT5_MODE}_dev "$PT5_PCI" "$PT_BUS" "$PT_ADDR"

echo "PCIe Passthrough Done"
