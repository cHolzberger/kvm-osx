./vfio-bind 0000:${GFXPCI}.0 0000:${GFXPCI}.1 0000:${USBPCI}.0

dev=0000:${GFXPCI}.0
vendor=$(cat /sys/bus/pci/devices/$dev/vendor | sed -e s/0x//)
device=$(cat /sys/bus/pci/devices/$dev/device | sed -e s/0x//)

echo "Vendor $vendor Device $device"
echo "Using roms/${vendor}_${device}.rom"
ROMFILE=roms/${vendor}_${device}.rom
#,
#BIOS_OPTS+=( -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 
BIOS_OPTS+=( -device vfio-pci,host=$GFXPCI.0,bus=pcie.0,rombar=1,romfile=$ROMFILE,x-vga=on,multifunction=on \
 -device vfio-pci,host=$GFXPCI.1,bus=pcie.0 
	)
CLOVER_OPTS+=( -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
 	-device vfio-pci,host=$GFXPCI.0,bus=root.1,multifunction=on,romfile=$ROMFILE,rombar=0 \
	-device vfio-pci,bus=root.1,host=$GFXPCI.1,rombar=0 ) 

QEMU_OPTS+=( -device vfio-pci,host=$USBPCI.0,addr=11.0,rombar=0 )


echo "Using GFX Card:"
lspci -s "$GFXPCI"
echo "Using USB Controller:"
lspci -s "$USBPCI"
