#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
set -o allexport
source $SCRIPT_DIR/config-common

hugepagesize=$(cat /proc/meminfo  | grep Hugepagesize: | cut -d":" -f 2 | sed -e "s/kB//" -e "s/ //g")

echo "Hugepageize: $hugepagesize"

if [ "x" != "x$hugepagesize" ]; then
	export USE_HUGEPAGES=1
	reservedmem=$RESERVE_RAM # GB
	
	let reservedkb=$reservedmem*1024*1024
	let nr_hugepages=$reservedkb/$hugepagesize
	echo "Reserving $reservedmem GB RAM => $nr_hugepages Hugepages"


	echo vm.nr_hugepages=$nr_hugepages 
	sysctl -w vm.nr_hugepages=$nr_hugepages || true
else 
	export USE_HUGEPAGES=0
	echo No Hugepages
fi
