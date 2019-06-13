set -x
if [[ "$VIRTIO_MODE" = "modern" ]]; then
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=on
		-global virtio-pci.disable-modern=off
		-global virtio-pci.modern-pio-notify=on
	)
else
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=off
		-global virtio-pci.disable-modern=on
		-global virtio-pci.modern-pio-notify=off
	)
fi

#could be pcie-root-port
STORE_ROOT_PORT=${STORE_ROOT_PORT:-"ioh3420"}
PT_ROOT_PORT=${PT_ROOT_PORT:-"ioh3420"}
NET_ROOT_PORT=${NET_ROOT_PORT-"pcie-root-port"}
STORE_ROOT_PORT=${STORE_ROOT_PORT:-"ioh3420"}
