echo "Using DUAL Virtio Network"
source $SCRIPT_DIR/../kvm/lib-net.sh

add_macvtap_iface "$NET1_BR" "$NET1_MACADDR"
add_macvtap_iface "$NET2_BR" "$NET2_MACADDR"
