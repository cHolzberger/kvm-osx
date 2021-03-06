#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -machine pc,accel=kvm
 -smbios type=2
 -nographic
 -rtc clock=vm,base=utc
)

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()
GFXPT_BUS="pci.0"
SCSI_BUS="pci.0"
NET_BUS="pci.0"
MACHINE_OS=mac
