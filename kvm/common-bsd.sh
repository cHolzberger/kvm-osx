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
	VPCI_BUS=( 0x6:off 0x7:off 0x8:off 0x9:off 0x0a:off 0x0b:off 0x0c:off 0x0d:off 0x0e:off
	       0x0f:off 0x10:off 0x11:off 0x12:off 0x13:off 0x14:off 0x15:off 0x16:off 0x17:off )



CLOVER_OPTS=()
BIOS_OPTS=()
	GFXPT_BUS="pcie.8"
	GFXPT_ADDR="0x0"
	QEMU_OPTS+=(
 -readconfig $SCRIPT_DIR/../cfg/q35--base_default.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35--mon.cfg
# -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35-addr3.0-port02-input.cfg 
 -readconfig $SCRIPT_DIR/../cfg/q35-addr5.0-port05-rng.cfg 
 -machine q35,accel=kvm,mem-merge=off,vmport=off
)


QEMU_OPTS+=(
 -m $MEM 
 -name "$MACHINE"
 -realtime mlock=off
# -smbios type=2
 -rtc base=utc
)
