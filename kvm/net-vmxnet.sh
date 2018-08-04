echo "Using VMXNET3"
QEMU_OPTS+=(
	-device vmxnet3,netdev=net0,id=net0,mac=$NET_MACADDR,addr=$(printf "%02x" 16) 
	-netdev bridge,id=net0,br=$NET_BR
)
