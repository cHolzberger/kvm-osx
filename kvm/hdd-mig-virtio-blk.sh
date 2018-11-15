source $SCRIPT_DIR/../kvm/lib-hdd.sh

add_virtio_pci_disk system
add_virtio_scsi_disk data
