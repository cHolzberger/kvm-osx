echo "Using DUAL Virtio Network"
QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net0,mac=$NET1_MACADDR 
 -netdev bridge,id=net0,br=$NET1_BR
)

QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net1,mac=$NET2_MACADDR 
 -netdev bridge,id=net1,br=$NET2_BR
)
