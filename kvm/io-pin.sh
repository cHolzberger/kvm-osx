#!/bin/bash
sleep 5
# openbsd-nc is important! 

if [ "x$MACHINE" == "x" ]; then
	echo "Usage:"
	echo "$0 [machine-name]"
	exit 3
fi

if [ ! -d "$MACHINE_PATH" ]; then
	echo "Machine $MACHINE does not exists"
	echo "Reason: $MACHINE_PATH does not exist"
	exit 1
fi
SOCKET=$MACHINE_PATH/var/control

source $MACHINE_PATH/config

echo "IO Pinning for $MACHINE with socket $SOCKET"
echo "Querying QEMU for VCPU Pids"
#tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-iothreads" }' | nc -NU "$SOCKET" |  sed -e "s/[,}{]/\n/g" | grep thread-id | cut -d":" -f 2 | xargs echo )
tasks=""
echo "Using CPUs: ${IO_CPUS[*]}"
echo $tasks
i=0

for t in $tasks ; do
	taskset -pc ${IO_CPUS[$i]} $t
	# be nice to cpu threads ;)
	renice -10 $t
	#chrt --rr -p 10 $t

	echo "Using Real CPU ${USE_CPUS[$i]} for IOThread $i"
	let i=$i+1
done
