echo "Using DUAL Virtio Network"
QEMU_OPTS+=(
-device virtio-net-pci,netdev=net0,mac=$NET1_MACADDR
 -netdev tap,id=net0,vhost=on,helper=\"/usr/lib/qemu/qemu-bridge-helper --br=$NET1_BR\"
)

QEMU_OPTS+=(
-device virtio-net-pci,netdev=net1,mac=$NET2_MACADDR
 -netdev tap,id=net1,vhost=on,helper=\"/usr/lib/qemu/qemu-bridge-helper --br=$NET2_BR\"
)
