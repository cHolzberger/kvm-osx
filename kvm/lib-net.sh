: ${NET_INDEX:=0}

function add_macvtap_iface() {
	NET_BR="$1"
	NET_MACADDR="$2"

	VTAP_MACHINE=$(echo $MACHINE | sed -e s/-//g)
	VTAP_MACHINE=${VTAP_MACHINE:0:13}
	VTAP_NAME="${VTAP_MACHINE}n$NET_INDEX"
	let FD_INDEX=NET_INDEX+3
	
	PRE_CMD+=(
		"test -x /sys/class/net/$VTAP_NAME && echo 'MACVTAP Device Exists: $VTAP_NAME, ... recreating it' && ip link del ${VTAP_NAME}"
		"sleep 1"
		"ip link add link ${NET_BR} name $VTAP_NAME address ${NET_MACADDR} type macvtap mode bridge"
		"sleep 1"
		"ip link set dev $VTAP_NAME up"
		"TAPNUM_${NET_INDEX}=\$(< /sys/class/net/$VTAP_NAME/ifindex)"
	)

	OPEN_FD+=(
		"$FD_INDEX<>/dev/tap\$TAPNUM_${NET_INDEX}"
	)
	QEMU_OPTS+=(
 		-netdev tap,id=net$NET_INDEX,vhost=on,fds=$FD_INDEX
	)

	_add_virtio_device $NET_MACADDR

        let NET_INDEX=NET_INDEX+1                                                         
}

function add_tap_iface() {
	NET_BR="$1"
	NET_MACADDR="$2"
	QEMU_OPTS+=(
 		-netdev tap,id=net$NET_INDEX,vhost=on,helper=\"/usr/lib/qemu/qemu-bridge-helper --br=$NET_BR\"
	)
	_add_virtio_device $NET_MACADDR

        let NET_INDEX=NET_INDEX+1                                                         
}

function _add_virtio_device() {
	NET_MACADDR=$1
	QEMU_OPTS+=(
 		-device virtio-net-pci,mq=on,vectors=12,netdev=net$NET_INDEX,mac=$NET_MACADDR
	)
}


