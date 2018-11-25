#+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+xsaves,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe

QEMU_OPTS=(	
 -enable-kvm 
 -m $MEM 
 -machine pc,accel=kvm,usb=off
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