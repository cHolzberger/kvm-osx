#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-net.sh

[[ ! -z "$NET1_MODE" ]] && add_${NET1_MODE}_iface "$NET1_DEV" "$NET1_VF" "$NET1_MACADDR" "$NET1_BUS" "$NET1_ADDR"
[[ ! -z "$NET2_MODE" ]] && add_${NET2_MODE}_iface "$NET2_DEV" "$NET2_VF" "$NET2_MACADDR" "$NET2_BUS" "$NET2_ADDR"

echo "Network Done"
