source $SCRIPT_DIR/../kvm/lib-hdd.sh

add_virtio_scsi_disk clover
add_virtio_scsi_disk system
add_virtio_scsi_disk data
add_virtio_scsi_disk data1
add_virtio_scsi_disk data2
