[[ -e $MEM_PATH-ram ]] && rm $MEM_PATH-ram

if [[ ! -z "1" ]]; then
	NUMA_NODES=1
	MEMORY_FLAGS+=(
	-m $MEM
 	-mem-prealloc
	-mem-path $MEM_PATH
	-object memory-backend-file,mem-path=$MEM_PATH-ram,size=${MEM},id=mem,share=on,prealloc=yes
	-numa node,memdev=mem
	)
else
	MEM_DIVIDED=$(( $MEMORY / $NUMA_NODES ))
	CPUS_PER_NODE=$(( $NUM_CPUS / $NUMA_NODES ))

	if [ "$CPUS_PER_NODE" -lt 1 ]; then
		echo "Not enough CPUs for NUMA count $NUMA_NODES, set with -C $NUMA_NODES or higher"
		exit 1
	fi

	HOST_NUMA_NODES=$(lscpu | awk '/^NUMA node\(s\):/ { print $3 }')

	NODE=0
	S=0
	E=$(( $CPUS_PER_NODE - 1 ))
	for CPU in $(seq 1 $NUMA_NODES); do
		# e.g.
		# -object memory-backend-file,mem-path=/dev/hugepages,size=131072M,id=ram-node0,host-nodes=0,policy=bind
		# -numa node,nodeid=0,memdev=ram-node0,cpus=0-31
		# -object memory-backend-file,mem-path=/dev/hugepages,size=131072M,id=ram-node1,host-nodes=1,policy=bind
		# -numa node,nodeid=1,memdev=ram-node1,cpus=32-63
		# [...]
		if [ $NODE -lt $HOST_NUMA_NODES ]; then
			MEMBIND=",host-nodes=${NODE},policy=bind"
		fi
		MEMORY_FLAGS+=(
			-object memory-backend-file,mem-path=/dev/hugepages,size=${MEM_DIVIDED}M,id=ram-node${NODE}${MEMBIND}
			-numa node,nodeid=${NODE},memdev=ram-node${NODE},cpus=${S}-${E}
		)
		NODE=$(( $NODE + 1 ))
		S=$(( $E + 1 ))
		E=$(( $S + $CPUS_PER_NODE - 1 ))
	done
fi
