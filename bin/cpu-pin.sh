#!/bin/bash
sleep 5
# openbsd-nc is important! 
SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config-common
source $SCRIPT_DIR/config-machine

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

echo "Querying QEMU for VCPU Pids"
tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' | nc -NU "$SOCKET" |  sed -e "s/[,}{]/\n/g" | grep thread_id | cut -d":" -f 2 | xargs echo )

echo "Using CPUs: ${USE_CPUS[*]}"
echo $tasks
i=0

for t in $tasks ; do
	taskset -pc ${USE_CPUS[$i]} $t
	# be nice to cpu threads ;)
	renice -15 $t
	#chrt --rr -p 10 $t

	echo "Using Real CPU ${USE_CPUS[$i]} for VCPU $i"
	let i=$i+1
done
