#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_MACHINE="q35"
VIRTIO_MODE="modern"

QEMU_OPTS=(
 -no-user-config
 -nodefaults
 -enable-kvm 
)

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()

if [[ "$QEMU_MACHINE" == "i440" ]]; then
	VPCI_BUS=( pci.0:0x10 pci.0:0x11 pci.0:0x12 pci.0:0x13 pci0.0x14 pci0.0x15 pci0.0x16 )

	NET1_BUS="pci.0"
	NET1_ADDR="0x10"

	NET2_BUS="pci.0"
	NET2_ADDR="0x11"

	SCSI_BUS="pci.0"
	SCSI_ADDR="0x1a"
	SCSI_CONTROLLER="single"

	GFXPT_BUS="pcie.8"
	GFXPT_ADDR="0x0"

	QEMU_OPTS+=(
 -readconfig $SCRIPT_DIR/../cfg/i440base.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440input.cfg
 -readconfig $SCRIPT_DIR/../cfg/guest-agent.cfg
 -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off,vmport=off
)

elif [[ "$QEMU_MACHINE" == "q35" ]]; then
	VPCI_BUS=( 0x1c.0:on 0x1c.1:off 0x1c.2:off 0x1c.3:off 0x1c.4:off 0x1c.5:off 0x1c.6:off 0x1c.7:off 0x1c.8:off
	       0x1d.0:on 0x1d.1:off 0x1d.2:off 0x1d.3:off 0x1d.4:off 0x1d.5:off 0x1d.6:off 0x1d.7:off 0x1d.8:off )

	GFXPT_BUS="gpu.1"
	GFXPT_ADDR="0x0"
	QEMU_CFG+=(
 -readconfig $SCRIPT_DIR/../cfg/q35--base_default.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35--mon.cfg
# -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35-addr3.0-port02-input.cfg 
 -readconfig $SCRIPT_DIR/../cfg/q35-addr5.0-port05-rng.cfg 
)
	QEMU_OPTS+=(
 	-machine q35,accel=kvm,kernel_irqchip=on,mem-merge=off,vmport=off
 	-readconfig $SCRIPT_DIR/../cfg/guest-agent.cfg
)
fi

#	SCSI_BUS="pcie.1"
#	SCSI_ADDR="0x0"
#	SCSI_CONTROLLER="single"

MACHINE_OS=linux

QEMU_OPTS+=(
 -m $MEM 
 -name "$MACHINE"
 -realtime mlock=off
# -smbios type=2
 -rtc base=utc
#  -overcommit mem-lock=on,cpu-pm=on
)
