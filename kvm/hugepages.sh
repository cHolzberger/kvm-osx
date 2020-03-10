#!/bin/bash

MACHINE_NAME="$MACHINE"

[[ ! -z "$MACHINE_NAME" ]] || echo "Machine ($MACHINE) name missing!"
[[ ! -z "$MACHINE_NAME" ]] || exit -1

MEM_PATH=/dev/hugepages/$MACHINE_NAME

#if [[ ! -d $MEM_PATH ]]; then
#      	mkdir -p $MEM_PATH
#fi

#MOUNTED=$( mount -t hugetlbfs 2>&1 | grep "$MEM_PATH" > /dev/null && echo 1 || echo 0 )

#if [[ "$MOUNTED" == "0" ]]; then
#	echo " ===> mounting hugetlbfs on $MEM_PATH"
#	mount -t hugetlbfs -o pagesize=1G "kvm-vm-$MACHINE_NAME" $MEM_PATH
#fi
#QEMU_OPTS+=( 
# -mem-path $MEM_PATH/$MACHINE_NAME
# -mem-prealloc
#)
