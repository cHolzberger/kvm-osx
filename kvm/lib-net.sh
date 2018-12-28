#!/bin/bash
source $SCRIPT_DIR/../kvm/lib-pt.sh

: ${NET_INDEX:=0}

if [[ -z "$NET_PCI_CURRENT_SLOT" ]]; then
	NET_PORT=netport
	NET_PCI_CURRENT_SLOT="1"
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



function add_macvtap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	CB=${6:-_add_virtio_device} 

	[[ -z "$NET_BR" ]] && echo "MACVTAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "MACVTAP: Macaddr empty" >&2  && return

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="m_${VTAP_MACHINE}n$NET_INDEX"
	let FD_INDEX=NET_INDEX+3
	
	PRE_CMD+=(
		"test -x /sys/class/net/$VTAP_NAME && echo MACVTAP Device Exists: $VTAP_NAME, ... recreating it && ip link del ${VTAP_NAME}"
		"sleep 1"
		"ip link add link ${NET_BR} name $VTAP_NAME address ${NET_MACADDR} type macvtap mode bridge"
		"sleep 1"
		"ip link set dev $VTAP_NAME up"
		"TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
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

	$CB $NET_MACADDR $NET_BUS $NET_ADDR
        let NET_INDEX=NET_INDEX+1                                                         
}

function add_tap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5	

	[[ -z "$NET_BR" ]] && echo "TAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "TAP: Macaddr empty" >&2  && return

	VNET_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VNET_MACHINE=${VTAP_MACHINE:0:11}
	VNET_NAME="vn${VTAP_MACHINE}n$NET_INDEX"

	QEMU_OPTS+=(
 		-netdev tap,id=net$NET_INDEX,vhost=on,helper=\"/usr/lib/qemu/qemu-bridge-helper --use-vnet --br=$NET_BR\"
	)
	_add_virtio_device $NET_MACADDR $NET_BUS $NET_ADD

        let NET_INDEX=NET_INDEX+1                                                         
}

function add_sriov_iface() {
	NETDEV=$1
	VIRTFN=$2
	MACADDR=$3
	NET_BUS=$4
	NET_ADDR=$5

	[[ -z "$NETDEV" ]] && echo "SRIOV: Netdev empty" >&2  && return
	[[ -z "$VIRTFN" ]] && echo "VIRTFN: Firtfn empty" >&2 && return
	[[ -z "$MACADDR" ]] && echo "MACADDR: Macaddr missing" >&2 && return

	sysfs=/sys/class/net/$NETDEV/device/virtfn$VIRTFN
	echo $sysfs
	PCIPORT=$(basename $(readlink $sysfs))
        ./vfio-bind $PCIPORT

	echo "Using Network SRV-IO from $NETDEV vf $VIRTFN" >&2
	ip link set $NETDEV down
	ip link set $NETDEV vf $VIRTFN mac $MACADDR
	ip link set $NETDEV vf $VIRTFN spoofchk off
	ip link set $NETDEV vf $VIRTFN trust on
	ip link set $NETDEV up
	
        QEMU_OPTS+=(-device vfio-pci,host=$PCIPORT,bus=$NET_BUS,addr=$NET_ADDR)
#rombar=0
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1
}

function _add_virtio_device() {
	NET_MACADDR=$1
	NET_BUS=$2
	NET_ADDR=$3	

	#DISABLE_OFFLX=",csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
	#DISABLE_OFFL=",csum=on,gso=on,guest_tso4=on,guest_tso6=on,guest_ecn=on"
	DISABLE_OFFL=",mrg_rxbuf=off"
	QEMU_OPTS+=(
 		-device virtio-net-pci$DISABLE_OFFL,bus=$NET_BUS,addr=$NET_ADDR,mq=on,vectors=6,netdev=net$NET_INDEX,mac=$NET_MACADDR
	)
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1
}


