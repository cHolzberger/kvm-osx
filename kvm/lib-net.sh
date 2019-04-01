#!/bin/bash:
source $SCRIPT_DIR/../kvm/lib-pt.sh

: ${NET_INDEX:=0}

if [[ -z "$NET_PCI_CURRENT_SLOT" ]]; then
	NET_PORT=netport
	NET_PCI_CURRENT_SLOT="1"
fi

if [[ -z "$NET_VIRTIO_CURRENT_SLOT" ]]; then
	NET_VIRTIO_CURRENT_SLOT="1"
fi

function add_vmxnet_iface () {
	add_macvtap_iface "$1" "$2" "$3" "$4" "$5" "_add_vmxnet_device"
}

function _add_vmxnet_device() {
	NET_MACADDR=$1
	NET_BUS=$2
	NET_ADDR=$3	

	#DISABLE_OFFLX=",csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
	#DISABLE_OFFL=",csum=on,gso=on,guest_tso4=on,guest_tso6=on,guest_ecn=on"
	QEMU_OPTS+=(
 		-device vmxnet3,bus=$NET_BUS,addr=$NET_ADDR,netdev=net$NET_INDEX,mac=$NET_MACADDR
	)
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1
}


function add_macvtapn_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5

	add_macvtap_iface "$NET_BR" "" "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "_add_virtio_device" "virtio-net"
}
function add_macvtap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	CB=${6:-_add_virtio_device} 
	QEMU_DEVICE=${7:-virtio-net-pci}

	[[ -z "$NET_BR" ]] && echo "MACVTAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "MACVTAP: Macaddr empty" >&2  && return

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="m_${VTAP_MACHINE}n$NET_INDEX"
	let FD_INDEX=NET_INDEX+3
	
	PRE_CMD+=(
		"test -x /sys/class/net/$VTAP_NAME && echo MACVTAP Device Exists: $VTAP_NAME, ... recreating it && ip link del dev ${VTAP_NAME}"
		"sleep 1"
		"ip link add link ${NET_BR} name $VTAP_NAME address ${NET_MACADDR} type macvtap mode bridge"
		"sleep 1"
		"ip link set dev $VTAP_NAME up"
		"TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	POST_CMD+=(
		"ip link del dev $VTAP_NAME"
	)

	OPEN_FD+=(
		"${FD_INDEX}0<>/dev/tap\$TAPNUM_${NET_INDEX}"
		"${FD_INDEX}1<>/dev/vhost-net"
	)
	FD="fd=${FD_INDEX}0"
	VD="vhostfd=${FD_INDEX}1"
	QEMU_OPTS+=(
 		-netdev "tap,$FD,id=net$NET_INDEX,vhost=on,$VD" 
	)

	$CB $NET_MACADDR $NET_BUS $NET_ADDR $QEMU_DEVICE
        let NET_INDEX=NET_INDEX+1                                                         
}

function add_tap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5	
	NET_VLAN=$6
	[[ -z "$NET_BR" ]] && echo "TAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "TAP: Macaddr empty" >&2  && return

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="t_${VTAP_MACHINE}n$NET_INDEX"
	
	PRE_CMD+=(
		"[[ ! -x /sys/class/net/$NET_BR ]] && echo BRIDGE Device does not exist: $NET_BR, ... creating it && ip link add $NET_BR type bridge"
		"[[ -x /sys/class/net/$VTAP_NAME ]] && echo MACVTAP Device Exists: $VTAP_NAME, ... recreating it && ip tuntap del dev ${VTAP_NAME} mode tap"
                "sleep 1"
                "ip tuntap add dev $VTAP_NAME mode tap"
		"ip link set $VTAP_NAME master $NET_BR"
                "sleep 1"
                "TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	POST_CMD+=(
		"ip tuntap del $VTAP_NAME mode tap"
	)


	if [[ "$NET_VLAN" = "isolated" ]]; then
		PRE_CMD+=(
		"ip link set $VTAP_NAME type bridge_slave isolated on"
		)
	else 
		PRE_CMD+=(
		"ip link set $VTAP_NAME type bridge_slave isolated off"
		)
	fi
	PRE_CMD+=(
                "ip link set dev $VTAP_NAME up"
	)

	QEMU_OPTS+=(
 		"-netdev tap,id=net$NET_INDEX,downscript=no,script=no,ifname=$VTAP_NAME"
	)
	_add_virtio_device $NET_MACADDR $NET_BUS $NET_ADD

        let NET_INDEX=NET_INDEX+1                                                         
}


function _add_pcie_iface() {
	PCIPORT=$1
	NET_BUS=$2
	NET_ADDR=$3

	[[ -z "$PCIPORT" ]] && echo "PCIPORT: Missing Device Addr" >&2  && return
	[[ -z "$NET_BUS" ]] && echo "PCIPORT: Missing NET BUS" >&2  && return
	[[ -z "$NET_ADDR" ]] && echo "PCIPORT: Missing NET ADDR" >&2  && return
       
	PRE_CMD+=(
	"echo 'PCIPORT: biding to $PCIPORT'"
	"$RUNTIME_PATH/vfio-bind $PCIPORT"
	)
	echo "Using Network from $PCIPORT" >&2
        QEMU_OPTS+=(-device vfio-pci,host=$PCIPORT,bus=$NET_BUS,addr=$NET_ADDR,rombar=0)
#rombar=0
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1

}

function add_vfio_iface() {
	NETDEV=$1
	NET_BUS=$4
	NET_ADDR=$5

	[[ -z "$NETDEV" ]] && echo "SRIOV: Netdev empty" >&2  && return

	PCIPORT=$NETDEV
	_add_pcie_iface $PCIPORT $NET_BUS $NET_ADDR
}

function add_sriov_iface() {
	NETDEV=$1
	VIRTFN=$2
	MACADDR=$3
	NET_BUS=$4
	NET_ADDR=$5
	NET_VLAN=$6

	[[ -z "$NETDEV" ]] && echo "SRIOV: Netdev empty" >&2  && return
	[[ -z "$VIRTFN" ]] && echo "VIRTFN: Firtfn empty" >&2 && return
	[[ -z "$MACADDR" ]] && echo "MACADDR: Macaddr missing" >&2 && return

	sysfs=/sys/class/net/$NETDEV/device/virtfn$VIRTFN
	echo $sysfs
	PCIPORT=$(basename $(readlink $sysfs))
	PRE_CMD+=(
	 	"echo 'Using Network SRV-IO from $NETDEV vf $VIRTFN'"
		#ip link set $NETDEV down
		"ip link set $NETDEV vf $VIRTFN mac $MACADDR"
		"sleep 1"
		"echo '$NETDEV::$VIRTFN -> $MACADDR'"
		"ip link set $NETDEV vf $VIRTFN spoofchk off"
		"sleep 1"
		"echo '$NETDEV::$VIRTFN -> spoofchk off'"
		"ip link set $NETDEV vf $VIRTFN trust on"
		"sleep 1"
		"echo '$NETDEV::$VIRTFN -> trust on'"
	)


	if [[ ! -z "$NET_VLAN" ]]; then
		PRE_CMD+=(
			"echo '$NETDEV::$VIRTFN -> Vlan $NET_VLAN'"
			"ip link set $NETDEV vf $VIRTFN vlan $NET_VLAN"
		)
	else
		PRE_CMD+=(
			"echo '$NETDEV::$VIRTFN -> diable Vlan'"
			"ip link set $NETDEV vf $VIRTFN vlan 0"
		)
	fi

	POST_CMD+=(
		"ip link set $NETDEV vf $VIRTFN mac 00:00:00:00:00:00"
	)


	#ip link set $NETDEV up
	
	_add_pcie_iface $PCIPORT $NET_BUS $NET_ADDR
}

function _add_virtio_device() {
	NET_MACADDR=$1
	NET_BUS="virtio.$NET_VIRTIO_CURRENT_SLOT"
	NET_ADDR="1"	
	DEVICE=${4:-virtio-net-pci}

	#DISABLE_OFFLX=",csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
	#DISABLE_OFFL=",csum=on,gso=on,guest_tso4=on,guest_tso6=on,guest_ecn=on"
	DISABLE_OFFL=",mrg_rxbuf=off"

	if [[ "$VIRTIO_MODE" = "modern" ]]; then
		VTM=",disable-legacy=on,disable-modern=off"
	else 
		VTM=",disable-legacy=off,disable-modern=off"
	fi

	QEMU_OPTS+=(
 		-device $DEVICE$DISABLE_OFFL,bus=$NET_BUS,addr=$NET_ADDR,mq=on,vectors=6,netdev=net$NET_INDEX,mac=$NET_MACADDR$VTM
	)
	let NET_VIRTIO_CURRENT_SLOT=$NET_VIRTIO_CURRENT_SLOT+1
}


