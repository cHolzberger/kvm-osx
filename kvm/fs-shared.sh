QEMU_OPTS+=(
	-fsdev proxy,id=fsdev0,socket=/mnt/9p/sock
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=shared 
)

