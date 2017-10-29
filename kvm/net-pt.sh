	echo "Using Network Passthrough"
	lspci -s "$NETPCI"

	./vfio-bind 0000:${NETPCI}
	
	QEMU_OPTS+=(-device vfio-pci,host=$NETPCI,addr=15.0,rombar=0) 
