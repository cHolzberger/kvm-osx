#!/bin/bash:

function add_ovs_iface() {
	NET_BR="$1"
	NET_VF="$2"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	NET_VLAN=$6
	QEMU_DEVICE=${7:-virtio-net-pci}
	CB=${8:-_add_virtio_device} 
	NET_ARGS=${9:-bridge}

	LBL="OVS[$NET_INDEX]"

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
		"test -x /sys/class/net/$VTAP_NAME && echo $LBL Device Exists: $VTAP_NAME, ... recreating it && ip addr flush dev ${VTAP_NAME} && ip link set ${VTAP_NAME} down && ip link del ${VTAP_NAME}"
		"(ovs-vsctl list-ports $NET_BR | grep ${VTAP_NAME}) && ovs-vsctl del-port $NET_BR ${VTAP_NAME}"
		"sleep 1"
		"ip tuntap add mode tap ${VTAP_NAME}"
		"ovs-vsctl add-port ${NET_BR} ${VTAP_NAME} $P_VLAN"
		"sleep 1"
		"ip link set dev $VTAP_NAME up"
		"TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	POST_CMD+=(
		"test -x /sys/class/net/$VTAP_NAME && echo $LBL Device Exists: $VTAP_NAME, ... recreating it && ip addr flush dev ${VTAP_NAME} && ip link set ${VTAP_NAME} down && ip link del ${VTAP_NAME}"
		"(ovs-vsctl list-ports $NET_BR | grep ${VTAP_NAME}) && ovs-vsctl del-port $NET_BR ${VTAP_NAME}"
	)

	OPEN_FD+=(
	#	"${FD_INDEX}0<>/dev/tap\$TAPNUM_${NET_INDEX}"
#		"${FD_INDEX}1<>/dev/vhost-net"
	)
#	FD="fd=${FD_INDEX}0"
#	VD="vhostfd=${FD_INDEX}1"
	QEMU_OPTS+=(
 		-netdev "tap,ifname=${VTAP_NAME},script=,downscript=,id=net$NET_INDEX" 
	)
	echo "Calling: $CB"
	$CB "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$QEMU_DEVICE"
        let NET_INDEX=NET_INDEX+1                                                         
}

