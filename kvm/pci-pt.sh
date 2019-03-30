#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh

[[ ! -z "$PT1_MODE" ]] && add_${PT1_MODE}_dev "$PT1_PCI" "$PT1_BUS" "$PT1_ADDR"
[[ ! -z "$PT2_MODE" ]] && add_${PT2_MODE}_dev "$PT2_PCI" "$PT2_BUS" "$PT2_ADDR"
[[ ! -z "$PT3_MODE" ]] && add_${PT3_MODE}_dev "$PT3_PCI" "$PT3_BUS" "$PT3_ADDR"
[[ ! -z "$PT4_MODE" ]] && add_${PT4_MODE}_dev "$PT4_PCI" "$PT4_BUS" "$PT4_ADDR"
[[ ! -z "$PT5_MODE" ]] && add_${PT5_MODE}_dev "$PT5_PCI" "$PT5_BUS" "$PT5_ADDR"

echo "PCIe Passthrough Done"
