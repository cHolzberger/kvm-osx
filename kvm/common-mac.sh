#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS+=(	
 -no-user-config
 -nodefaults
 -enable-kvm 
 -m $MEM 
 -machine pc-q35-4.2,accel=kvm,usb=off,kernel-irqchip=on
 -overcommit mem-lock=off,cpu-pm=off
 -smbios type=2
 -rtc clock=vm,base=utc,driftfix=slew
 -nographic
 #-usb
)
# -device "isa-applesmc,osk=\"ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc\""
# using virtualsmc.efi i nstread
VPCI_BUS=(  0x1c.0:on 0x1c.1:off 0x1c.2:on 0x1c.3:off 0x1c.4:off 0x1c.5:off 0x1c.6:off
       0x1c.7:off 0x1c.8:off 0x11:off 0x12:off 0x13:off 0x14:off 0x15:off 0x16:off 0x17:off )

QEMU_CFG+=(
 -readconfig $SCRIPT_DIR/../cfg/q35--base_default.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35--mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35-addr4.0-hp.cfg
# -readconfig $SCRIPT_DIR/../cfg/q35-addr3.0-port02-input.cfg 
 -readconfig $SCRIPT_DIR/../cfg/macinput.cfg 
 -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
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

#GFXPT_BUS="gpu.1"
GFXPT_BUS="gpu.1"
GFXPT_ADDR="0x00"

MACHINE_OS=mac
