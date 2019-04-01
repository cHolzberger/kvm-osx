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
 -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off,vmport=off
)

elif [[ "$QEMU_MACHINE" == "q35" ]]; then
	NET1_BUS="pcie.2"
	NET1_ADDR="0x0"

	NET2_BUS="pcie.3"
	NET2_ADDR="0x0"

	SCSI_BUS="pcie.1"
	SCSI_ADDR="0x0"
	SCSI_CONTROLLER="single"

	GFXPT_BUS="pcie.8"
	GFXPT_ADDR="0x0"
	QEMU_OPTS+=(
 -readconfig $SCRIPT_DIR/../cfg/q35base.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35input.cfg
 -machine q35,accel=kvm,kernel_irqchip=on,mem-merge=off,vmport=off
)

fi

	SCSI_BUS="pcie.1"
	SCSI_ADDR="0x0"
	SCSI_CONTROLLER="single"



QEMU_OPTS+=(
 -m $MEM 
 -name "$MACHINE"
 -realtime mlock=off
# -smbios type=2
 -rtc base=utc
)
