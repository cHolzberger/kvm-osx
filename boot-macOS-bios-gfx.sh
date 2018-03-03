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

GFXPCI=05:00
USBPCI=04:00

source kvm/common.sh
source kvm/net.sh
source kvm/hdd.sh
#source kvm/hugepages.sh
source kvm/pt.sh

qemu-system-x86_64 \
	${BIOS_OPTS[@]} \
	${QEMU_OPTS[@]} \
	  -vga std \
	  -serial stdio \
	  -kernel bios/enoch_rev2883_boot \

