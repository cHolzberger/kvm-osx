#!/bin/bash

# qemu-img create -f qcow2 mac_hdd.img 64G
# echo 1 > /sys/module/kvm/parameters/ignore_msrs
#
# Type the following after boot,
# -v "KernelBooter_kexts"="Yes" "CsrActiveConfig"="103"
#
# printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))
#
# no_floppy = 1 is required for OS X guests!
#
# Commit 473a49460db0a90bfda046b8f3662b49f94098eb (qemu) makes "no_floppy = 0"
# for pc-q35-2.3 hardware, and OS X doesn't like this (it hangs at "Waiting for
# DSMOS" message). Hence, we switch to pc-q35-2.4 hardware.
#
# Network device "-device e1000-82545em" can be replaced with "-device vmxnet3"
# for possibly better performance.

source kvm/common.sh
source kvm/net.sh
source kvm/hdd.sh


GFXPCI=05:00
USBPCI=08:00

./vfio-bind 0000:$GFXPCI.0 0000:$GFXPCI.1 0000:$USBPCI.0

qemu-system-x86_64 \
	${QEMU_OPTS[@]} \
	  -vga none \
	  -bios efi/ovmf.somlo.fd \
 	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -device ioh3420,bus=pcie.0,addr=05.0,multifunction=on,port=1,chassis=1,id=root.1 \
        -device vfio-pci,host=$GFXPCI.0,bus=root.1,romfile=roms/r280x.rom,addr=0.0,multifunction=on \
        -device vfio-pci,host=$GFXPCI.1,bus=root.1,addr=0.1 \


