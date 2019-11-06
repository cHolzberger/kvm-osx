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

function add_e1000_iface() {
	add_macvtap_iface "$1" "$2" "$3" "$4" "$5" "$6" "e1000-82545em" "_add_e1000_device" 
}

function _add_e1000_device() {
	NET_MACADDR=$1
	NET_BUS=$2
	NET_ADDR=$3	

	#DISABLE_OFFLX=",csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
	#DISABLE_OFFL=",csum=on,gso=on,guest_tso4=on,guest_tso6=on,guest_ecn=on"
	QEMU_OPTS+=(
 		-device e1000-82545em,bus=$NET_BUS,addr=$NET_ADDR,netdev=net$NET_INDEX,mac=$NET_MACADDR
	)
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1
}
function add_vmxnet_iface () {
	add_macvtap_iface "$1" "$2" "$3" "$4" "$5" "$6" "vmxnet" "_add_vmxnet_device" 
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


function add_macvtap_passthru_iface() {
	NET_BR="$1"
	NET_VF="$2"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	NET_VLAN=$6

	add_macvtap_iface "$NET_BR" "$NET_VF" "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$NET_VLAN" "virtio-net" "_add_virtio_device" "passthru"
}


function add_macvtap_iface() {
	NET_BR="$1"
	NET_VF="$2"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5
	NET_VLAN=$6
	QEMU_DEVICE=${7:-virtio-net-pci}
	CB=${8:-_add_virtio_device} 
	NET_ARGS=${9:-bridge}

	[[ -z "$NET_BR" ]] && echo "MACVTAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "MACVTAP: Macaddr empty" >&2  && return
	echo "'$NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"
	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="m_${VTAP_MACHINE}n$NET_INDEX"
	
	if [[ "$NET_ARGS" == "passthru" ]]; then
		sysfs=/sys/class/net/$NET_BR/device/virtfn$NET_VF
		PCIPORT=$(basename $(readlink $sysfs))
		ptname=${NET_BR}v${NET_VF}
		PRE_CMD+=(		
		"echo '$NET_BR::$NET_VF -> macvtap passthru'"
		"drv-bind igbvf $PCIPORT"
		"echo '$NET_BR::$NET_VF -> bringing interface down'"
		"ip link set $ptname down"
		"echo '$NET_BR::$NET_VF -> setting mtu'"
		"ip link set $NET_BR mtu 1500"
		"ip link set $ptname down"
		"ip link set $ptname mtu 1500"
		"echo '$NET_BR::$NET_VF -> setting macaddr $NET_MACADDR'"
		"ip link set $NET_BR vf $NET_VF mac '$NET_MACADDR'"
		"echo '$NET_BR::$NET_VF -> setting VLAN $NET_VLAN'"
		"ip link set $NET_BR vf $NET_VF vlan $NET_VLAN"
		"echo '$NET_BR::$NET_VF -> disableing spoofchk'"
		"ip link set $NET_BR vf $NET_VF spoofchk off"
		"echo '$NET_BR::$NET_VF -> setting trust'"
		"ip link set $NET_BR vf $NET_VF trust on"
		"echo '$NET_BR::$NET_VF -> bringing interface up'"
		"ip link set $ptname up"
		)
		NET_BR=$ptname
	fi

	PRE_CMD+=(
		"test -x /sys/class/net/$VTAP_NAME && echo MACVTAP Device Exists: $VTAP_NAME, ... recreating it && ip link del dev ${VTAP_NAME}"
		"sleep 1"
		"echo '$NET_BR::$VTAP_NAME -> setting mode $NET_ARGS'"
		"ip link add link ${NET_BR} name $VTAP_NAME address $NET_MACADDR type macvtap mode ${NET_ARGS}"
		"sleep 1"
		"ip link set dev $VTAP_NAME up"
		"TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	POST_CMD+=(
		"ip link del dev $VTAP_NAME"
	)
	let FD_INDEX=NET_INDEX+3 
	FD="fd=${FD_INDEX}0"
	OPEN_FD+=( 
		"${FD_INDEX}0<>/dev/tap\$TAPNUM_${NET_INDEX}"
	)
	
		OPEN_FD+=(
			"${FD_INDEX}1<>/dev/vhost-net"
		)
		VD="vhostfd=${FD_INDEX}1"
		QEMU_OPTS+=(
 			-netdev "tap,$FD,id=net$NET_INDEX,vhost=on,vhostforce=on,$VD" 
		)
	echo "Calling: $CB"
	$CB "$NET_MACADDR" "$NET_BUS" "$NET_ADDR" "$QEMU_DEVICE"
        let NET_INDEX=NET_INDEX+1                                                         
}

function add_bridge_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5	
	NET_VLAN=$6
	NET_MEMBER=$7
	CB=${8:-_add_virtio_device} 
	[[ -z "$NET_BR" ]] && echo "BR: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "BR: Macaddr empty" >&2  && return
	echo "'$NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="t_${VTAP_MACHINE}n$NET_INDEX"

	QEMU_OPTS+=(
 		"-netdev bridge,id=net$NET_INDEX,br=$NET_BR"
	)
	$CB $NET_MACADDR $NET_BUS $NET_ADDR

        let NET_INDEX=NET_INDEX+1                                                         
}

function add_tap_iface() {
	NET_BR="$1"
	NET_MACADDR="$3"
	NET_BUS=$4
	NET_ADDR=$5	
	NET_VLAN=$6
	NET_MEMBER=$7
	[[ -z "$NET_BR" ]] && echo "TAP: Netdev empty" >&2  && return
	[[ -z "$NET_MACADDR" ]] && echo "TAP: Macaddr empty" >&2  && return
	echo "'$NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:11}
	VTAP_NAME="t_${VTAP_MACHINE}n$NET_INDEX"

	QEMU_OPTS+=(
 		"-netdev tap,id=net$NET_INDEX,downscript=/etc/qemu/tapdown,script=/etc/qemu/tapup,ifname=$VTAP_NAME"
	)
	_add_virtio_device $NET_MACADDR $NET_BUS $NET_ADDR

        let NET_INDEX=NET_INDEX+1                                                         
}


function _add_pcie_iface() {
	PCIPORT=$1
	NET_BUS=$2
	NET_ADDR=$3

	[[ -z "$PCIPORT" ]] && echo "PCIPORT: Missing Device Addr" >&2  && return
	[[ -z "$NET_BUS" ]] && echo "PCIPORT: Missing NET BUS" >&2  && return
	[[ -z "$NET_ADDR" ]] && echo "PCIPORT: Missing NET ADDR" >&2  && return
       
	echo "'$NET_BR::$NET_VF Args -> NET_BR=$NET_BR NET_VF=$NET_VF NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR NET_VLAN=$NET_VLAN QEMU_DEVICE=$QEMU_DEVICE CB=$CB NET_ARGS=$NET_ARGS"
	PRE_CMD+=(
	"echo 'PCIPORT: biding to $PCIPORT'"
	"$RUNTIME_PATH/vfio-bind $PCIPORT"
	)
	echo "Using Network from $PCIPORT" >&2
        QEMU_OPTS+=(-device vfio-pci,tx_queue_size=1024,rx_queue_size=1024,host=$PCIPORT,bus=$NET_BUS,addr=$NET_ADDR,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mrg_rxbuf=off,rombar=0)
#rombar=0
	let NET_PCI_CURRENT_SLOT=$NET_PCI_CURRENT_SLOT+1

}

function add_vfio_iface() {
	NETDEV=$1
	NET_BUS=$4
	NET_ADDR=$5

	[[ -z "$NETDEV" ]] && echo "SRIOV: Netdev empty" >&2 && return

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
		"echo '$NETDEV::$VIRTFN -> $MACADDR'"
		"ip link set $NETDEV vf $VIRTFN mac $MACADDR"
		"sleep 1"
		
		"echo '$NETDEV::$VIRTFN -> spoofchk off'"
		"ip link set $NETDEV vf $VIRTFN spoofchk off"
		"sleep 1"
		
		"echo '$NETDEV::$VIRTFN -> trust on'"
		"ip link set $NETDEV vf $VIRTFN trust on"
		"sleep 1"
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
		"ip link set dev $NETDEV vlan 0"
		"ip link set dev $NETDEV vf $VIRTFN mac 00:00:00:00:00:00"
	)


	#ip link set $NETDEV up
	
	_add_pcie_iface $PCIPORT $NET_BUS $NET_ADDR
}

function _add_virtio_device() {
	DISABLE_OFFL=",mrg_rxbuf=off,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
	
	NET_MACADDR=$1
	NET_BUS="${2:-virtio.$NET_VIRTIO_CURRENT_SLOT}"
	NET_ADDR="${3:-'0'}"	
	DEVICE=${4:-virtio-net-pci}
	OPTS=${5:-$DISABLE_OFFL}
	echo "'$NET_BR::$NET_VF _add_virtio_device -> NET_MACADDR=$NET_MACADDR NET_BUS=$NET_BUS NET_ADDR=$NET_ADDR DEVICE=$DEVICE"
	#DISABLE_OFFL=",mrg_rxbuf=off"
	ENABLE_MQ=",mq=on,vectors=8"
	QUEUE_SIZE=",tx_queue_size=1024,rx_queue_size=1024"
	VTM=""

	case $VIRTIO_MODE in
		modern)
		VTM=",disable-legacy=on,disable-modern=off,modern-pio-notify=on,ats=on"$DISABLE_OFFL""$ENABLE_MQ""$QUEUE_SIZE
		;;
		transitional)
		VTM=",disable-legacy=off,disable-modern=off,modern-pio-notify=off,ats=on"$DISABLE_OFFL""$ENABLE_MQ""$QUEUE_SIZE
		;;
		*)
		VTM=",disable-legacy=off,disable-modern=on"$QUEUE_SIZE""$DISABLE_OFFL
		;;
	esac
#,mq=on,vectors=6
	QEMU_OPTS+=(
 		-device $DEVICE""$VTM,bus=$NET_BUS,addr=$NET_ADDR,netdev=net$NET_INDEX,mac=$NET_MACADDR
	)
	let NET_VIRTIO_CURRENT_SLOT=$NET_VIRTIO_CURRENT_SLOT+1
}

source $SCRIPT_DIR/../kvm/lib-net-ovs.sh
source $SCRIPT_DIR/../kvm/lib-net-vpp.sh
