echo "Using E1000 Network"
QEMU_OPTS+=(
 -device e1000,netdev=net0,id=net0,mac=$NET_MACADDR 
 -netdev bridge,id=net0,br=$NET_BR
)
