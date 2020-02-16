#!/bin/bash
MACHINE_NAME=$MACHINE

[[ -z "$MACHINE_NAME" ]] && echo "Missing machine name" &&  exit -1

MEM_PATH=/dev/hugepages2M
