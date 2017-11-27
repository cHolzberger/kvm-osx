echo "Using DUAL Virtio Network"
QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net0,id=net0,mac=$NET1_MACADDR 
 -netdev bridge,id=net0,br=br0
)

QEMU_OPTS+=(
 -device virtio-net-pci,netdev=net1,id=net1,mac=$NET2_MACADDR 
 -netdev bridge,id=net1,br=br1
)
