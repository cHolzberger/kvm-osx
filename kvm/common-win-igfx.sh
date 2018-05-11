#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off
 -name "$MACHINE"
 -realtime mlock=off
 -smbios type=2
 )

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()