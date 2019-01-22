#!?bin/bash

if [[ -d "/sys/fs/cgroup/cpuset" ]]; then
	CPUSET="/sys/fs/cgroup/cpuset"
elif [[ -d "/dev/cpuset" ]]; then
	CPUSET="/dev/cpuset"
else
	mkdir /dev/cpuset
	mount -t cpuset none /dev/cpuset
	CPUSET=/dev/cpuset 
fi

CPUSET_DIR="$CPUSET/kvm/$MACHINE"

C_MEMS="${CPUSET_PREFIX}mems"
C_CPUS="${CPUSET_PREFIX}cpus"
C_TASKS="tasks"
C_SCHED="${CPUSET_PREFIX}sched_load_balance"

DEF_MEMSET=$(cat $CPUSET/$C_MEMS)
DEF_CPUSET=$(cat $CPUSET/$C_CPUS)

function destroy_cpuset() {
	VMNAME=$1
	#-- 
	[[ ! -d "$CPUSET/kvm/$VMNAME" ]] && return
	C_D=$( realpath "$CPUSET/kvm/$VMNAME" )
	echo "Destroying CPUSET: $C_D"

	[[ -d $C_D/io ]] && echo -e "\tRemoving: $C_D/io" && rmdir $C_D/io

	[[ -d $C_D/qemu ]] && echo -e "\tRemoving $C_D/qemu" && rmdir $C_D/qemu

	for i in $C_D/vcpu*; do
		[[ -d $i ]] && echo -e "\tRemoving: $i" && rmdir $i
	done

	[[ -d $C_D ]] && echo -e "\tRemoving $C_D" && rmdir $C_D
}

function create_cloned_cpuset() {
	VMNAME=$1
	CPUS=${2:-$DEF_CPUSET}
	#-----
	DIR="$CPUSET/kvm/$VMNAME" 
	test -d "$DIR" && echo "$DIR allready exists" && return
	mkdir -p "$DIR"
	DIR=$( realpath "$DIR" )
	echo "CPUSET for Group: $GROUP"
	echo -e "\tcreating $DIR"

	echo -e "\tSetting $DIR/$C_MEMS: $DEF_MEMSET"
	echo -n "$DEF_MEMSET" > $DIR/$C_MEMS
	echo -e "\tSetting $DIR/$C_CPUS: $CPUS"
	echo -n "$CPUS" > $DIR/$C_CPUS
}
