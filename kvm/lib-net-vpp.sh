#!/bin/bash:

function add_vpp_iface() {
	NET_BR="$1"
	NET_VF="$2"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	NET_VLAN=$6
	QEMU_DEVICE=${7:-virtio-net-pci}
	CB=${8:-_add_virtio_device} 
	NET_ARGS=${9:-bridge}

	LBL="VPP[$NET_INDEX]"

	[[ -z "$NET_BR" ]] && echo "$LBL: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "$LBL: Macaddr empty" >&2  && return
	echo "'$LBL: $NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"
	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="o_${VTAP_MACHINE}n$NET_INDEX"

	let FD_INDEX=NET_INDEX+3
	
	[[ ! -z $NET_VLAN ]] && P_VLAN="tag=$NET_VLAN"
	[[ ! -z $NET_VLAN ]] && O_VLAN=",vlan=$NET_VLAN"
	PRE_CMD+=(
	)

	POST_CMD+=(
	)

	OPEN_FD+=(
	)
	QEMU_OPTS+=(
		-object memory-backend-file,id=mem,size=1024M,mem-path=/dev/hugepages,share=on 
		-chardev socket,id=nchar$NET_INDEX,path=$NET_BR
 		-netdev "vhost-user,vhostforce,chardev=nchar$NET_INDEX,id=net$NET_INDEX" 
	)
	echo "Calling: $CB"
	$CB "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$QEMU_DEVICE"
        let NET_INDEX=NET_INDEX+1                                                         
}

