#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_MACHINE="pc-i440fx"
QEMU_CFG+=(
 -readconfig $SCRIPT_DIR/../cfg/i440base.cfg
# -readconfig $SCRIPT_DIR/../cfg/i440rng.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440mon.cfg
 -readconfig $SCRIPT_DIR/../cfg/i440input.cfg
 -readconfig $SCRIPT_DIR/../cfg/guest-agent.cfg
)
QEMU_OPTS+=(	
 -no-user-config
 -nodefaults
 -nographic
 -enable-kvm 
 -m $MEM 
 -machine pc-i440fx-4.2,accel=kvm,kernel_irqchip=on,mem-merge=off 
 -overcommit mem-lock=on,cpu-pm=off
 -smbios type=2
 -rtc base=utc
 )
VPCI_BUS=( 0x10:off 0x11:off 0x12:off 0x13:off pci0.0x14:off pci0.0x15:ff pci0.0x16:off )
#VPCI_BUS=( 0x1c.0:on 0x1c.1:off 0x1c.2:off 0x1c.3:off 0x1c.4:off 0x1c.5:off 0x1c.6:off 0x1c.7:off 0x1c.8:off
#      0x1d.0:on 0x1d.1:off 0x1d.2:off 0x1d.3:off 0x1d.4:off 0x1d.5:off 0x1d.6:off 0x1d.7:off 0x1d.8:off )

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
NET1_ADDR="0x0"

NET2_BUS="pci.0"
NET2_ADDR="0x0"

SCSI_BUS="pci.0"
SCSI_ADDR="0x0"
SCSI_CONTROLLER="single"

#GFXPCI="gpu.1"
#GFXPT_BUS="pcie.8"
#GFXPT_ADDR="0x0"

MACHINE_OS=win
