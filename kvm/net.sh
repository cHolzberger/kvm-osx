
if [ "x$NETPCI" != "x" ]; then
	echo "Using Network Passthrough"
	lspci -s "$NETPCI"

	./vfio-bind 0000:${NETPCI}
	
	QEMU_OPTS+=(-device vfio-pci,host=$NETPCI,addr=15.0,rombar=0) 
elif [ "x$E1000_MACADDR" != "x" ]; then
	echo "Using E1000 Network"
	QEMU_OPTS+=(-device e1000,netdev=net0,id=net0,mac=$E1000_MACADDR -netdev tap,id=net0,script=bin/qemu-ifup)
elif [ "x$MACADDR" != "x" ]; then
	echo "Using VMXNET3"
	QEMU_OPTS+=(-device vmxnet3,netdev=net0,id=net0,mac=$MACADDR -netdev tap,id=net0,script=bin/qemu-ifup)
fi
