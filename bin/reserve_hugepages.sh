#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config-common

hugepagesize=$(cat /proc/meminfo  | grep Hugepagesize: | cut -d":" -f 2 | sed -e "s/kB//" -e "s/ //g")
reservedmem=$RESERVE_RAM # GB

let reservedkb=$reservedmem*1024*1024
let nr_hugepages=$reservedkb/$hugepagesize
echo "Reserving $reservedmem GB RAM => $nr_hugepages Hugepages"

sysctl -w vm.nr_hugepages=$nr_hugepages || true
