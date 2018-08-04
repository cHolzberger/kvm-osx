echo "Using E1000 Network"
QEMU_OPTS+=(
-device e1000-82545em,netdev=net0,id=net0,mac=$NET_MACADDR,addr=$(printf "%02x" 16)
 -netdev bridge,id=net0,br=$NET_BR
)
