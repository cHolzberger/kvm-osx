mkdir /etc/modprobe.d
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf 
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/vfio_iommu_type1.conf
echo "options kvm ignore_msrs=1" >> /etc/modprobe.d/kvm.conf


