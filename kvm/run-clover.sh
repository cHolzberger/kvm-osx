CMD="qemu-system-x86_64"
MON_PATH="$VM_PREFIX/$MACHINE/var"
SOCKET=$MACHINE_PATH/var/control

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

# qemu gets io priority

echo "#!/bin/bash" > $MACHINE_PATH/run
echo "cd $MACHINE_PATH" >> $MACHINE_PATH/run
printf "#PRE-CMD BEGINN" >> $MACHINE_PATH/run

printf "%s" "${PRE_CMD[@]/#/$'\n'}" >> $MACHINE_PATH/run

printf "\n#PRE-CMD END\n" >> $MACHINE_PATH/run

IFS=, echo $CMD \
       ${CLOVER_OPTS[@]} \
	${QEMU_SW[@]} \
        ${QEMU_OPTS[@]} \
	${QEMU_EXTRA_OPTS[@]} \
	-S \
	-pidfile $MON_PATH/pid \
	${OPEN_FD[@]} \
	-writeconfig $MACHINE_PATH/qemu.cfg >> $MACHINE_PATH/run

chmod u+x $VM_PREFIX/$MACHINE/run
	#--daemonize \

source $SCRIPT_DIR/../kvm/cpu-pin-cpuset.sh
source $SCRIPT_DIR/../kvm/io-pin-cpuset.sh 

# start execution
QMP_CMD+=(
'{ "execute": "cont" }' 
)

echo "" >  $VM_PREFIX/$MACHINE/qmp_commands
for i in "${QMP_CMD[@]}" ; do
	echo "Running QMP Commands: $i"
	printf "%s\n" "$i" >> $VM_PREFIX/$MACHINE/qmp_commands  
	qmp-send "$MACHINE" "$i"
done

#$SCRIPT_DIR/../bin/console $MACHINE
while [[ -e /proc/$QEMU_PID ]] > /dev/null; do 
	#echo $MACHINE running...
	
	$SCRIPT_DIR/machine-info "$MACHINE:$SEAT"
	sleep 5;
 done;

