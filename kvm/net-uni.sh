#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-net.sh

[[ ! -z "$NET1_MODE" ]] && add_${NET1_MODE}_iface "$NET1_DEV" "$NET1_VF" "$NET1_MACADDR" "$NET1_BUS" "$NET1_ADDR" "$NET1_VLAN"
[[ ! -z "$NET2_MODE" ]] && add_${NET2_MODE}_iface "$NET2_DEV" "$NET2_VF" "$NET2_MACADDR" "$NET2_BUS" "$NET2_ADDR" "$NET2_VLAN"
[[ ! -z "$NET3_MODE" ]] && add_${NET3_MODE}_iface "$NET3_DEV" "$NET3_VF" "$NET3_MACADDR" "$NET3_BUS" "$NET3_ADDR" "$NET3_VLAN"
[[ ! -z "$NET4_MODE" ]] && add_${NET4_MODE}_iface "$NET4_DEV" "$NET4_VF" "$NET4_MACADDR" "$NET4_BUS" "$NET4_ADDR" "$NET4_VLAN"

echo "Network Done"

