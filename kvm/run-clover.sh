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

cat > $MACHINE_PATH/run <<-END
#!/bin/bash
cd "$MACHINE_PATH" 

function on_begin() {
	$(printf "%s" "${PRE_CMD[@]/#/$'\n'}")
}

function on_run() {
$CMD \
	-serial unix:$MACHINE_PATH/var/console,server,nowait \
       ${CLOVER_OPTS[@]} \
	${QEMU_SW[@]} \
        ${QEMU_OPTS[@]} \
	${QEMU_EXTRA_OPTS[@]} \
	-S \
	-pidfile $MON_PATH/pid \
	-writeconfig $MACHINE_PATH/qemu.cfg \
	-D $MACHINE_PATH/var/debug.log \
	${OPEN_FD[@]} 
}

function on_exit() {
 err="$?"

 echo "Done ... cleaing up"
 trap '' EXIT 


  $(printf "%s" "${POST_CMD[@]/#/$'\n'}")

   echo "Exit Code: $err" 
 if [[ -e $MACHINE_PATH/var/pid ]]; then
        p="\$(cat $MACHINE_PATH/var/pid)"
        
	rm $MACHINE_PATH/var/pid
        
	if [ -e "/proc/$p" ]; then
                kill $p
        fi

 fi
 exit $err
}

trap on_exit EXIT 

on_begin
on_run

END



chmod u+x $VM_PREFIX/$MACHINE/run
CMD=$MACHINE_PATH/run
echo "Qemu is: " $(which qemu-system-x86_64)
echo "Running: $CMD"
$CMD & 
CMD_PID=$!
sleep 3
echo "" >  $VM_PREFIX/$MACHINE/qmp_commands
for i in "${QMP_CMD[@]}" ; do
	echo "Running QMP Commands: $i"
	printf "%s\n" "$i" >> $VM_PREFIX/$MACHINE/qmp_commands  
	echo qmp-send "$MACHINE" "$i" 
	qmp-send "$MACHINE" "$i" 
done


source $SCRIPT_DIR/../kvm/cpu-pin-cpuset.sh
source $SCRIPT_DIR/../kvm/io-pin-cpuset.sh 

# start execution
QMP_CMD_POST+=(
'{ "execute": "cont" }' 
)

for i in "${QMP_CMD_POST[@]}" ; do
	echo "Running QMP POST Commands: $i"
	printf "%s\n" "$i" >> $VM_PREFIX/$MACHINE/qmp_commands  
	qmp-send "$MACHINE" "$i"
done

#$SCRIPT_DIR/../bin/console $MACHINE
$SCRIPT_DIR/machine-info "$MACHINE:$SEAT"
RUNNING=$?
while [[ "$RUNNING" == "0" ]]; do 
	#echo $MACHINE running...
	sleep 5;
	$SCRIPT_DIR/machine-info "$MACHINE:$SEAT"
	RUNNING=$?
 done;

