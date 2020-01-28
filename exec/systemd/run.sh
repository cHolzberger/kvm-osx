#!/bin/bash

set -e 
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
#CMD="ionice -c 2 -n 3 $CMD"
#CMD="/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[*]} -n -15 -e $CMD"
IFS="$OIFS"
# set dma
exec 10> /dev/cpu_dma_latency


echo -e -n '10' >&10
#echo -e -n '-1' > /proc/sys/kernel/sched_rt_runtime_us

echo "Qemu is: " $(which qemu-system-x86_64)
echo "Running: $CMD"
#systemd-run --no-block --unit=qemu-${MACHINE/-/__} --slice=qemu machine-boot-kickstart $MACHINE || true 
systemd-run --no-block --unit=qemu-${MACHINE/-/__} --scope --slice=qemu $CMD 
#\
# 2>$MACHINE_LOG/qemu.stderr.log \
# 1>$MACHINE_LOG/qemu.stdout.log &
#CMD_PID=$!

