#!/bin/bash

MACHINE_NAME="$MACHINE"

[[ ! -z "$MACHINE_NAME" ]] || echo "Machine ($MACHINE) name missing!"
[[ ! -z "$MACHINE_NAME" ]] || exit -1

MEM_PATH=/tmp/mem/$MACHINE_NAME-1g
if [[ ! -d $MEM_PATH ]]; then
      	mkdir -p $MEM_PATH
	mount -t hugetlbfs -o pagesize=1G none $MEM_PATH
	#MEM_PATH=/dev/hugepages
fi

QEMU_OPTS+=( 
 -mem-path $MEM_PATH
 -mem-prealloc
)
