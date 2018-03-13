source $SCRIPT_DIR/../kvm/lib-hdd.sh

add_ahci_disk system
add_virtio_pci_disk data
