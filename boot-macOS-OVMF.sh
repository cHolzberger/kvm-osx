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
MACADDR=52:54:00:c9:18:27
qemu-system-x86_64 -enable-kvm -m 3072 -cpu Penryn,kvm=off,vendor=GenuineIntel \
	  -machine q35,accel=kvm \
	  -smp 2,cores=2 \
	  -bios efi/ovmf.somlo.fd \
	  -usb -device usb-kbd -device usb-tablet \
 	  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
	  -smbios type=2 \
	  -device ide-drive,bus=ide.2,drive=MacHDD \
	  -drive id=MacHDD,if=none,file=./mac_hdd.img \
	  -monitor stdio \
	  -vnc 0.0.0.0:0 -k en-us \
	  -device e1000-82545em,netdev=net0,id=net0,mac=$MACADDR -netdev tap,id=net0,script=bin/qemu-ifup
# 	  -netdev user,id=hub0port0 -device e1000-82545em,netdev=hub0port0,id=mac_vnet0 \

