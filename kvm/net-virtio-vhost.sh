echo "Using VIRTIO VHOST Network"
source $SCRIPT_DIR/../kvm/lib-net.sh

NET_BR=${NET_BR:br0}
add_tap_iface "$NET_BR" "$NET_MACADDR"

