echo "Using DUAL E1000 Network"
QEMU_OPTS+=(
 -device e1000,netdev=net0,id=net0,mac=$NET1_MACADDR 
 -netdev bridge,id=net0,br=br0
)

QEMU_OPTS+=(
 -device e1000,netdev=net1,id=net1,mac=$NET2_MACADDR 
 -netdev bridge,id=net1,br=br1
)
