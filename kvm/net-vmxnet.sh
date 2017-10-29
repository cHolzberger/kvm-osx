
echo "Using VMXNET3"
QEMU_OPTS+=(-device vmxnet3,netdev=net0,id=net0,mac=$MACADDR -netdev tap,id=net0,script=bin/qemu-ifup)
