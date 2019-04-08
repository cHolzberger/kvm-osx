#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS=(	
 -no-user-config
 -nodefaults
 -readconfig $SCRIPT_DIR/../cfg/macbase.cfg
 -readconfig $SCRIPT_DIR/../cfg/macmon.cfg
 -enable-kvm 
 -m $MEM 
 -machine pc-q35-3.0,accel=kvm,usb=off
 -name "$MACHINE"
 -realtime mlock=off
 -smbios type=2
 -device "isa-applesmc,osk=\"ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc\""
 -rtc clock=vm,base=utc
 -nographic
 -usb
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

SCSI_BUS="pcie.1"
SCSI_ADDR="0x0"

GFXPT_BUS="pcie.7"
GFXPT_ADDR="0x0"

MACHINE_OS=mac
