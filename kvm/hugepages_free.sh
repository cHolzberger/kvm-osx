#!/bin/bash
MACHINE_NAME=$MACHINE

[[ -z "$MACHINE_NAME"]] && echo "Missing machine name" &&  exit -1

MEM_PATH=/tmp/mem/$MACHINE_NAME-1g
if [[ -d $MEM_PATH ]]; then
	umount $MEM_PATH
fi
