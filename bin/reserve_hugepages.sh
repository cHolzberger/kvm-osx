#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config-common

hugepagesize=$(cat /proc/meminfo  | grep Hugepagesize: | cut -d":" -f 2 | sed -e "s/kB//" -e "s/ //g")
if [ "x" != "x$hugepagesize" ]; then
	export USE_HUGEPAGES=1
reservedmem=$RESERVE_RAM # GB

let reservedkb=$reservedmem*1024*1024/2
#let nr_hugepages=$reservedkb/$hugepagesize
echo "Reserving $reservedmem GB RAM => $nr_hugepages Hugepages"

sysctl -w vm.nr_hugepages=$nr_hugepages || true
else 
	export USE_HUGEPAGES=0
	echo No Hugepages
fi
