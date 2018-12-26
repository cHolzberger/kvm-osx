#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_OPTS=(	
 -no-user-config
 -nodefaults
 -readconfig $SCRIPT_DIR/../cfg/i440base.cfg
 -enable-kvm 
 -m $MEM 
 -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off,max-ram-below-4g=1G
 -name "$MACHINE"
 -realtime mlock=on
 -smbios type=2
 -rtc base=utc
 -object rng-random,id=rng0,filename=/dev/urandom 
 -device virtio-rng-pci,rng=rng0
 )

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

GFXPT_BUS="pcie.8"
GFXPT_ADDR="0x0"
