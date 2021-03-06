#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
# settings von https://forum.level1techs.com/t/increasing-vfio-vga-performance/133443/19

QEMU_OPTS+=(	
 -no-user-config 
 -nodefaults 
 -enable-kvm 
# -m $MEM 
# -machine pc-q35-4.2,accel=kvm,kernel_irqchip=on,usb=off,dump-guest-core=off
# -name "$MACHINE",process="qemu:q35:$MACHINE"
 -smbios type=2
 -rtc base=utc
 -net none
 )

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()
#VPCI_BUS=( 0x1c.0:on 0x1c.1:off 0x1c.2:off 0x1c.3:off 0x1c.4:off 0x1c.5:off 0x1c.6:off 0x1c.7:off 0x1c.8:off
#      0x1d.0:on 0x1d.1:off 0x1d.2:off 0x1d.3:off 0x1d.4:off 0x1d.5:off 0x1d.6:off 0x1d.7:off 0x1d.8:off )

VPCI_BUS=( 0x1a.0:on 0x1a.1:off 0x1a.2:off 0x1a.3:off 0x1d.4:off 0x1d.5:off 0x1c.6:off 0x1c.7:off 0x1c.8:off )

#GFXPCI="gpu.1"
GFXPT_BUS="gpu.1"
GFXPT_ADDR="0x0"
if [[ $GFX_MODE == "pt" ]]; then
 CLOVER_OPTS+=( 	
 	-readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
 )
fi

if [[ $USB_MODE != "pt" ]]; then
	CLOVER_OPTS+=( 	
 -readconfig $SCRIPT_DIR/../cfg/q35-addr3.0-port02-input.cfg 
 )
fi


QEMU_CFG+=(
 -readconfig $SCRIPT_DIR/../cfg/q35--base_default.cfg
# -readconfig $SCRIPT_DIR/../cfg/q35-addr2.0-port01-gpu.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35--mon.cfg
)

MACHINE_OS=win
