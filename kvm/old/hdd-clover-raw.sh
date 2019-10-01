source $SCRIPT_DIR/../kvm/lib-hdd.sh

add_ahci_disk clover
add_ahci_disk system
add_ahci_disk data

#VVFAT - not working atm
# QEMU_OPTS+=(
#	  -device ide-drive,bus=ide.1,drive=EfiHDD 
#  -drive id=EfiHDD,if=none,file=fat:fat-type=16:rw:$VM_PREFIX/$MACHINE/efi/,format=vvfat,media=disk
#)


