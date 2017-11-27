echo "Using E1000 Network"
QEMU_OPTS+=(
 -device e1000,netdev=net0,id=net0,mac=$MACADDR 
 -netdev tap,id=net0,script=bin/qemu-ifup,downscript=bin/qemu-ifdown
)
