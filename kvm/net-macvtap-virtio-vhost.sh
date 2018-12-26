echo "Using Virtio Network"
source $SCRIPT_DIR/../kvm/lib-net.sh
add_macvtap_iface "$NET_BR" "" "$NET_MACADDR"
