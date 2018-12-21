#!/bin/bash

for i in /proc/irq/*/smp_affinity
do
	irq=$(basename $(dirname $i))
	map=$(cat $i | awk '{print toupper($0)}')
	res=$(echo "obase=2; ibase=16; $map" | bc)
	printf "irq%2s %.8d (0x%s)\n" "$irq" "$res" "$map"
done
