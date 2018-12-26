#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS=(	
 -device intel-iommu
 -enable-kvm 
 -m $MEM 
 -machine pc-q35-2.11,accel=kvm,usb=off
 -name "$MACHINE"
 -realtime mlock=off
 -smbios type=2
 -device "isa-applesmc,osk=\"ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc\""
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
GFXPT_BUS="pcie.0"
SCSI_BUS="pcie.0"
NET_BUS="pcie.0"
