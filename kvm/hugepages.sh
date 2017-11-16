QEMU_OPTS+=( 
 -mem-path /dev/hugepages/kvm-$MACHINE 
 -mem-prealloc
 -balloon none 
)
