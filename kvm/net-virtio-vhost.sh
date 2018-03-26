echo "Using VIRTIO Network"
NET_BR=${NET_BR:br0}

QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net0,mac=$NET_MACADDR
 -netdev tap,id=net0,vhost=on,helper=\"/usr/lib/qemu/qemu-bridge-helper --br=$NET_BR\"
)
