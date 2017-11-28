CMD="qemu-system-x86_64"
MON_PATH="$VM_PREFIX/$MACHINE/var"

set -e 
OIFS="$IFS"
IFS=","
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
#CMD="ionice -c 2 -n 3 $CMD"
#CMD="/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[*]} -n -15 -e $CMD"
IFS="$OIFS"

echo $CMD \
        ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} 

# set dma
exec 10> /dev/cpu_dma_latency
echo -e -n '10' >&10
#echo -e -n '-1' > /proc/sys/kernel/sched_rt_runtime_us

# qemu gets io priority
$CMD \
       ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
	${QEMU_EXTRA_OPTS[@]} \
	-pidfile $MON_PATH/pid &
sleep 1
QEMU_PID=$(cat $MON_PATH/pid)
echo "QEMU pid is $QEMU_PID"

cpu-pin.sh $MACHINE 
io-pin.sh $MACHINE 

while [ -e /proc/$QEMU_PID ] > /dev/null; do sleep 1; done;

