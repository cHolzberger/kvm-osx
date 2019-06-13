#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-net.sh
source $SCRIPT_DIR/../kvm/lib-pci.sh

[[ ! -z "$NET1_MODE" ]] && add_vpci VPCI_NAME $NET_ROOT_PORT && add_${NET1_MODE}_iface "$NET1_DEV" "$NET1_VF" "$NET1_MACADDR" "$VPCI_NAME" "0x0" "$NET1_VLAN" 
[[ ! -z "$NET2_MODE" ]] && add_vpci VPCI_NAME $NET_ROOT_PORT && add_${NET2_MODE}_iface "$NET2_DEV" "$NET2_VF" "$NET2_MACADDR" "$VPCI_NAME" "0x0" "$NET2_VLAN"
[[ ! -z "$NET3_MODE" ]] && add_vpci VPCI_NAME $NET_ROOT_PORT && add_${NET3_MODE}_iface "$NET3_DEV" "$NET3_VF" "$NET3_MACADDR" "$VPCI_NAME" "0x0" "$NET3_VLAN"
[[ ! -z "$NET4_MODE" ]] && add_vpci VPCI_NAME $NET_ROOT_PORT && add_${NET4_MODE}_iface "$NET4_DEV" "$NET4_VF" "$NET4_MACADDR" "$VPCI_NAME" "0x0" "$NET4_VLAN"

echo "Network Done"

