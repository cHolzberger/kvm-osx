#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
# settings von https://forum.level1techs.com/t/increasing-vfio-vga-performance/133443/19

QEMU_OPTS=(	
 -no-user-config 
 -nodefaults 
 -readconfig $SCRIPT_DIR/../cfg/q35base.cfg
 -readconfig $SCRIPT_DIR/../cfg/default-q35-base.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/q35input.cfg
 -enable-kvm 
 -m $MEM 
 -machine pc-q35-3.0,accel=kvm,kernel_irqchip=on,mem-merge=off,usb=off,vmport=off,dump-guest-core=off
 -name "$MACHINE",process="qemu:q35:$MACHINE"
 -realtime mlock=off
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

NET1_BUS="pcie.2"
NET1_ADDR="0x0"

NET2_BUS="pcie.3"
NET2_ADDR="0x0"

SCSI_BUS="pcie.1"
SCSI_ADDR="0x0"
SCSI_CONTROLLER="single"

GFXPT_BUS="pcie.8"
GFXPT_ADDR="0x0"

MACHINE_OS=win
