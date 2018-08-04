#!/bin/bash

#https://de.scribd.com/document/261321898/Red-Hat-Enterprise-Linux-7-Virtualization-Tuning-and-Optimization-Guide-en-US-pdf
echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter

# see: https://www.kernel.org/doc/ols/2009/ols2009-pages-169-184.pdf
sysctl -w net.ipv4.tcp_timestamps=0

#if network reliable:
sysctl -w net.ipv4.tcp_sack=0

#see:https://darksideclouds.wordpress.com/2016/10/10/tuning-10gb-nics-highway-to-hell/

# Maximum receive socket buffer size
sysctl -w net.core.rmem_max=134217728 

# Maximum send socket buffer size
sysctl -w net.core.wmem_max=134217728 

# Minimum, initial and max TCP Receive buffer size in Bytes
sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728"

# Minimum, initial and max buffer space allocated
sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"

# Maximum number of packets queued on the input side
sysctl -w net.core.netdev_max_backlog=300000 

# Auto tuning
sysctl -w net.ipv4.tcp_moderate_rcvbuf=1

# Don't cache ssthresh from previous connection
sysctl -w net.ipv4.tcp_no_metrics_save=1

# The Hamilton TCP (HighSpeed-TCP) algorithm is a packet loss based congestion control and is more aggressive pushing up to max bandwidth (total BDP) and favors hosts with lower TTL / VARTTL.
sysctl -w net.ipv4.tcp_congestion_control=htcp

# If you are using jumbo frames set this to avoid MTU black holes.
sysctl -w net.ipv4.tcp_mtu_probing=1
