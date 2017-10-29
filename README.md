#Clover and QEmu
http://www.nicksherlock.com/2016/11/using-clover-uefi-boot-with-sierra-on-proxmox/

#QCow Base Image:

https://dustymabe.com/2015/01/11/qemu-img-backing-files-a-poor-mans-snapshotrollback/

##Create a disk with backing-file:
qemu-img create -f qcow2 -b /guests/F21server.img /guests/F21server.qcow2


## Hugepages
https://wiki.archlinux.org/index.php/KVM

# Take a look at
https://bugs.launchpad.net/qemu/+bug/1619991

# iMessage
http://www.fitzweekly.com/2016/02/hackintosh-imessage-tutorial.html

# Mac9P
https://github.com/benavento/mac9p/releases

# LVM mit Cache
https://www.thomas-krenn.com/de/wiki/LVM_Caching_mit_SSDs_einrichten

# ISOLate Cpus and set Hugepagesize (CPU Support needed)
isolcpus=1-13 nohz_full=1-13 rcu_nocbs=1-13 hugepagesz=1GB hugepages=64 default_hugepagesz=1GB
