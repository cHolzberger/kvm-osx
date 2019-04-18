#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_MACHINE="q35"
VIRTIO_MODE="transitional"

QEMU_OPTS=(
 -enable-kvm 
 -no-user-config
 -nodefaults
 -device ipmi-bmc-sim,id=bmc
)

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID

	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()

	NET1_BUS="pcie.2"
	NET1_ADDR="0x0"
	NET2_BUS="pcie.3"
	NET2_ADDR="0x0"
	NET3_BUS="pcie.4"
	NET3_ADDR="0x0"
	NET4_BUS="pcie.5"
	NET4_ADDR="0x0"

	SCSI_BUS="pcie.1"
	SCSI_ADDR="0x0"
	SCSI_CONTROLLER="single"

	GFXPT_BUS="pcie.8"
	GFXPT_ADDR="0x0"
	QEMU_OPTS+=(
 -readconfig $SCRIPT_DIR/../cfg/q35base.cfg
 -readconfig $SCRIPT_DIR/../cfg/bsd-q35-base.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35input.cfg
 -machine q35,accel=kvm,mem-merge=off,vmport=off
)


QEMU_OPTS+=(
 -m $MEM 
 -name "$MACHINE"
 -realtime mlock=off
# -smbios type=2
 -rtc base=utc
)
