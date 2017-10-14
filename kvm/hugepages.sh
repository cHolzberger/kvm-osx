QEMU_OPTS+=( 
 -mem-path /dev/hugepages/kvm 
 -mem-prealloc
 -balloon none 
)
