#!/bin/bash
MACHINE_NAME=$MACHINE

[[ -z "$MACHINE_NAME" ]] && echo "Missing machine name" &&  exit -1

MEM_PATH=/tmp/mem/$MACHINE_NAME-1g

MOUNTED=$( mount -t hugetlbfs 2>&1 | grep "$MEM_PATH" > /dev/null && echo 1 || echo 0 )

if [[ $MOUNTED ]]; then
	echo " ===> unmounting hugetlbfs on $MEM_PATH"
	umount $MEM_PATH
fi
