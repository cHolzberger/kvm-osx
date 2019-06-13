#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS=(	
 -no-user-config
 -nodefaults
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

VPCI_BUS=( 0x6:off 0x7:off 0x8:off 0x9:off 0x0a:off 0x0b:off 0x0c:off 0x0d:off 0x0e:off
       0x0f:off 0x10:off 0x11:off 0x12:off 0x13:off 0x14:off 0x15:off 0x16:off 0x17:off )

QEMU_CFG+=(
 -readconfig $SCRIPT_DIR/../cfg/q35--base_default.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35--mon.cfg
# -readconfig $SCRIPT_DIR/../cfg/q35-addr3.0-port02-input.cfg 
# -readconfig $SCRIPT_DIR/../cfg/q35-addr5.0-port05-rng.cfg 
)

PT_ROOT_PORT=ioh3420
USB_ROOT_PORT=ioh3420
NET_ROOT_PORT=ioh3420
STORE_ROOT_PORT=ioh3420

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()

GFXPT_BUS="gpu.1"
GFXPT_ADDR="0x0"

MACHINE_OS=mac
