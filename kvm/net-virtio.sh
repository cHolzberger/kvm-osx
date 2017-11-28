echo "Using VIRTIO Network"
${NET_BR:=br0}

QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net0,id=net1,id=net0,mac=$NET_MACADDR 
 -netdev bridge,id=net1,br=$NET_BR
)
