#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe
QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -machine pc,accel=kvm,kernel_irqchip=on,mem-merge=off,vmport=off
 -name "$MACHINE"
 -realtime mlock=off
 -smbios type=2
 -rtc clock=vm,base=utc
 -device virtio-rng-pci
 )

if [ "x$UUID" != "x" ]; then
	QEMU_OPTS+=(
		-uuid $UUID
	)
fi
CLOVER_OPTS=()
BIOS_OPTS=()
GFXPT_BUS="pci.0"
