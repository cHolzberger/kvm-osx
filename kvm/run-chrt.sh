CMD="/opt/qemu/bin/qemu-system-x86_64"
MON_PATH="$MACHINE_VAR"

OIFS="$IFS"
IFS=","
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
#CMD="ionice -c 2 -n 3 $CMD"
CMD="/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[*]} -n -15 -e $CMD"
CMD="/srv/kvm/OSX-KVM/bin/chrt --rr 5 $CMD"
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
