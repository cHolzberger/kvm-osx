#-cpu Penryn,kvm=off,vendor=GenuineIntel,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=blah  \
QEMU_OPTS+=( -usb \
#	-device usb-kbd 
	-device virtio-keyboard-pci
	-vnc 0.0.0.0:0 -k en-us \
	)

BIOS_OPTS+=( 
#	-device usb-mouse 
	-device virtio-tablet-pci
)
CLOVER_OPTS+=( -device usb-tablet )
