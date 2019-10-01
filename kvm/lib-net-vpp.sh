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
	VTAP_MACHINE=$MACHINE
#	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
#	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="qemu_${VTAP_MACHINE}_$NET_INDEX"

	let FD_INDEX=NET_INDEX+3
	VAR="vp$NET_INDEX"
	SOCK="/run/vpp/$VTAP_NAME.sock"
	IFNAME="/run/vpp/$VTAP_NAME.ifname"
	[[ ! -z $NET_VLAN ]] && P_VLAN="tag=$NET_VLAN"
	[[ ! -z $NET_VLAN ]] && O_VLAN=",vlan=$NET_VLAN"
	PRE_CMD+=(
	"[[ -S $SOCK ]] && VPPPORT=\$( cat $IFNAME ) && vppctl delete vhost-user \$VPPPORT && rm $SOCK && rm $IFNAME && echo Destroyed \$VPPPORT"
	"[[ ! -S $SOCK ]] && VPPPORT=\$( vppctl create vhost socket $SOCK hwaddr $NET_MACADDR | tee  $IFNAME ) || VPPPORT=\$( cat $IFNAME )"
	"vppctl set interface state \$VPPPORT up"
	"vppctl set interface mtu 1500 \$VPPPORT "
	"vppctl set interface l2 bridge \$VPPPORT $NET_BR"
	)
		

	POST_CMD+=(
	"[[ -S $SOCK ]] && VPPPORT=\$( cat $IFNAME ) && vppctl delete vhost-user \$VPPPORT && rm $SOCK && rm $IFNAME && echo Destroyed \$VPPPORT"
	)

	OPEN_FD+=(
	)


	if [[ "$VIRTIO_MODE" = "modern" ]]; then
	XTRA=",queues=3"
	else 
	XTRA=""
	fi
	QEMU_OPTS+=(
		-chardev socket,id=nchar$NET_INDEX,path=$SOCK,logfile=$SOCK.log,nowait,server
 		-netdev "vhost-user,vhostforce=on,chardev=nchar$NET_INDEX,id=net$NET_INDEX"$XTRA 
	)
	echo "Calling: $CB"
	$CB "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$QEMU_DEVICE"
        let NET_INDEX=NET_INDEX+1                                                         
}

function add_vpptap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5	
	NET_VLAN=$6
	QEMU_DEVICE=${7:-virtio-net-pci}
	CB=${8:-_add_virtio_device} 
	[[ -z "$NET_BR" ]] && echo "TAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "TAP: Macaddr empty" >&2  && return
	echo "'$NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="t_${VTAP_MACHINE}n$NET_INDEX"
	IFNAME="/run/vpp/$VTAP_NAME.ifname"
	
	PRE_CMD+=(
		"[[ -e $IFNAME ]] && VPPPORT=\$( cat $IFNAME ) && vppctl delete tap \$VPPPORT && rm $IFNAME && echo Destroyed \$VPPPORT"
		"echo '$NETDEV::$VTAP_NAME * creating $VTAP_NAME'"
		"VPPPORT=\$( vppctl create tap host-if-name $VTAP_NAME hw-addr 52:54:00:AB:2E:ED host-mac-addr 52:54:00:AB:2E:ED | tee $IFNAME )"
		"vppctl set interface state \$VPPPORT up"
		"vppctl set interface mtu 1500 \$VPPPORT "
		"vppctl set interface l2 bridge \$VPPPORT $NET_BR"

                "TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	POST_CMD+=(
		"[[ -e $IFNAME ]] && VPPPORT=\$( cat $IFNAME ) && vppctl delete tap \$VPPPORT && rm $IFNAME && echo Destroyed \$VPPPORT"
	)

	let FD_INDEX=NET_INDEX+3
	OPEN_FD+=(
		"${FD_INDEX}0<>/dev/tap\$TAPNUM_${NET_INDEX}"
	)

	
	QEMU_OPTS+=(
 		-netdev "tap,fd=${FD_INDEX}0,id=net$NET_INDEX" 
	)
	$CB "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$QEMU_DEVICE" ""
        let NET_INDEX=NET_INDEX+1    
}
