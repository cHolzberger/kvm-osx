CMD="qemu-system-x86_64"
MON_PATH="$VM_PREFIX/$MACHINE/var"

OIFS="$IFS"
IFS=","
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
CMD="ionice -c 2 -n 3 $CMD"
IFS="$OIFS"

echo $CMD \
        ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} 

# qemu gets io priority
$CMD \
       ${CLOVER_OPTS[@]} \
        ${QEMU_OPTS[@]} \
	${QEMU_EXTRA_OPTS[@]} \
	--daemonize \
	-pidfile $MON_PATH/pid

QEMU_PID=$(cat $MON_PATH/pid)
echo "QEMU pid is $QEMU_PID"
