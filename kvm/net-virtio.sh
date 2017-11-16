echo "Using VIRTIO Network"
QEMU_OPTS+=(
	-device virtio-net-pci,netdev=net0,id=net0,bootindex=2,mac=$MACADDR 
	-netdev tap,id=net0,script=bin/qemu-ifup
)
