echo "Using VIRTIO Network"
NET_BR=${NET_BR:br0}

QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net0,mac=$NET_MACADDR 
 -netdev bridge,id=net0,br=$NET_BR
)
