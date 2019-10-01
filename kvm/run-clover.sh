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
nohup $CMD \
 2>$MACHINE_PATH/var/qemu.stderr.log \
 1>$MACHINE_PATH/var/qemu.stdout.log &
CMD_PID=$!


if ! wait-for-state $MACHINE prelaunch; then
	echo "Machine is down!"
	exit 1
fi

echo "" >  $VM_PREFIX/$MACHINE/qmp_commands

for i in "${QMP_CMD[@]}" ; do
	echo "Running QMP Commands: $i"
	printf "%s\n" "$i" >> $VM_PREFIX/$MACHINE/qmp_commands  
	echo qmp-send "$MACHINE" "$i" 
	qmp-send "$MACHINE" "$i" 
done

source $SCRIPT_DIR/../kvm/run-cpu-pin-cpuset.sh
source $SCRIPT_DIR/../kvm/run-io-pin-cpuset.sh 



for i in "${QMP_CMD_POST[@]}" ; do
	echo "Running QMP POST Commands: $i"
	printf "%s\n" "$i" >> $VM_PREFIX/$MACHINE/qmp_commands  
	qmp-send "$MACHINE" "$i"
done


if [[ ! -z \$VIRT_INPUT ]]; then
	echo "0" > $MACHINE_PATH/var/evdev_state
	echo "#usb" > $MACHINE_PATH/var/usb_state
	input-attach $MACHINE
fi      

if ! wait-for-state $MACHINE running; then
	echo "Machine is down!"
		exit 1
fi
#restore stdout and stderr
$SCRIPT_DIR/machine-info "$MACHINE:$SEAT"
RUNNING=$?
while [[ "$RUNNING" == "0" ]]; do 
	#echo $MACHINE running...
	sleep 5;
	$SCRIPT_DIR/machine-info "$MACHINE:$SEAT"
	RUNNING=$?
 done;

