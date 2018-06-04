#MEM_PATH=$MACHINE_PATH/mem
MEM_PATH=/dev/hugetlbfs
#test -d $MEM_PATH || mkdir $MEM_PATH
#umount $MEM_PATH || true
#mount -t hugetlbfs -o pagesize=1G none $MEM_PATH

QEMU_OPTS+=( 
 -mem-path $MEM_PATH
 -mem-prealloc
)
