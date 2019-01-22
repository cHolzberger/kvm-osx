#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_OPTS=(	
 -no-user-config
 -nodefaults
 -nographic
 -readconfig $SCRIPT_DIR/../cfg/i440base.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440input.cfg
 -enable-kvm 
 -m $MEM 
 -machine pc-i440fx-3.1,accel=kvm,kernel_irqchip=on,mem-merge=off -name "$MACHINE"
 -realtime mlock=off
 -smbios type=2
 -rtc base=utc
 )
#,max-ram-below-4g=1G
#
if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()

NET1_BUS="pci.0"
NET1_ADDR="0x10"

NET2_BUS="pci.0"
NET2_ADDR="0x11"

SCSI_BUS="pci.0"
SCSI_ADDR="0x1a"
SCSI_CONTROLLER="single"

GFXPT_BUS="pcie.8"
GFXPT_ADDR="0x0"
