modprobe tun
modprobe br_netfilter

brctl addbr br0
brctl addif br0 eth0

ifconfig br0 192.168.254.169 netmask 255.255.255.0
ifconfig eth0 0
route add default gw 192.168.254.1
#ip link add br0 type bridge
#ip link set eth1 master br0
