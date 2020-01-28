set -x

case $VIRTIO_MODE in
	modern)
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=on
		-global virtio-pci.disable-modern=off
		-global virtio-pci.modern-pio-notify=on
	);;
	transitional)
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=off
		-global virtio-pci.disable-modern=off
		-global virtio-pci.modern-pio-notify=off
	)
	;;
	*)
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=off
		-global virtio-pci.disable-modern=on
		-global virtio-pci.modern-pio-notify=off
	)
	;;
esac

i=0
CPUCOUNT=${#USE_CPUS[@]}
for t in ${USE_CPUS[@]} ; do                          
        CPUNUM=${USE_CPUS[$i]}
		QEMU_OPTS+=(
			"-vcpu vcpunum=$i,affinity=$CPUNUM"
		)
        let i="($i + 1)"
done 



QEMU_OPTS+=(
	-chardev socket,id=monitor,path=$MACHINE_PATH/var/monitor,server,nowait 
	-chardev socket,id=qmp,path=$MACHINE_PATH/var/qmp,nowait,server	
	-chardev socket,id=tty0,path=$MACHINE_POATH/var/tty0,nowait,server
	-monitor chardev:monitor	
	-qmp chardev:qmp
	-serial chardev:tty0
	-name $MACHNE,debug-threads=on
)
#could be pcie-root-port
USB_ROOT_PORT=${USB_ROOT_PORT:-"pcie-root-port"}
NET_ROOT_PORT=${NET_ROOT_PORT-"pcie-root-port"}
PT_ROOT_PORT=${PT_ROOT_PORT:-"ioh3420"}
STORE_ROOT_PORT=${STORE_ROOT_PORT:-"ioh3420"}

#GFXMODE 
GFX_MODE=${GFX_MODE:-uni}
