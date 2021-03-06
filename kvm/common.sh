set -x

case $VIRTIO_MODE in
	modern)
	QEMU_OPTS+=(
#		-global virtio-pci.disable-legacy=on
#		-global virtio-pci.disable-modern=off
#		-global virtio-pci.modern-pio-notify=on
	);;
	transitional)
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=off
		-global virtio-pci.disable-modern=off
		-global virtio-pci.modern-pio-notify=off
	)
	;;
	default)
	QEMU_OPTS+=(
		-global virtio-pci.disable-legacy=off
		-global virtio-pci.disable-modern=on
		-global virtio-pci.modern-pio-notify=off
	)
	;;
	*)
	echo "disable virtio overrides"
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

case $POWERSAVE in 
	full)
	QEMU_OPTS+=(
	-global PIIX4_PM.disable_s3=0 
	-global PIIX4_PM.disable_s4=0
	-global ICH9-LPC.disable_s3=0
	);;
	*)
	QEMU_OPTS+=(
	-global PIIX4_PM.disable_s3=1
	-global PIIX4_PM.disable_s4=1
	-global ICH9-LPC.disable_s3=1
	);;
esac

	

QEMU_OPTS+=(
        -readconfig $SCRIPT_DIR/../cfg/ipmi.cfg
#        -readconfig $SCRIPT_DIR/../cfg/spice-stream.cfg
	-chardev socket,id=monitor,path=$MACHINE_PATH/var/monitor,server,nowait 
	-chardev socket,id=qmp,path=$MACHINE_PATH/var/qmp,nowait,server	
	-chardev socket,id=tty0,path=$MACHINE_POATH/var/tty0,nowait,server
	-monitor chardev:monitor	
	-qmp chardev:qmp
	-serial chardev:tty0
	#-name $MACHNE,debug-threads=on
 	-overcommit mem-lock=off,cpu-pm=off
)
GFXPT_BUS="gpu.1"
GFXPT_ADDR="0x0"
GFX_AUDIO="pt"
#could be pcie-root-port
USB_ROOT_PORT=${USB_ROOT_PORT:-"pcie-root-port"}
NET_ROOT_PORT=${NET_ROOT_PORT-"pcie-root-port"}
PT_ROOT_PORT=${PT_ROOT_PORT:-"ioh3420"}
STORE_ROOT_PORT=${STORE_ROOT_PORT:-"ioh3420"}

#GFXMODE 
GFX_MODE=${GFX_MODE:-uni}
