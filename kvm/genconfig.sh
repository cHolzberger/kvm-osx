# start execution
QMP_CMD=(
'{ "execute": "qmp_capabilities" }'
)


QMP_CMD_POST+=(
'{ "execute": "cont" }' 
)



source kvm/lib-helper.sh
source kvm/common-$OS.sh
source kvm/bios-$BIOS.sh
source kvm/cpu-$CPU_MODEL.sh
source kvm/usb-$USB_MODE.sh
source kvm/gfx-$GFX_MODE.sh
source kvm/hdd-$HDD_MODE.sh
source kvm/teradici.sh 


[[ ! -z "$NET_MODE" ]] && source kvm/net-$NET_MODE.sh

if [[ ! -z "$NET1_MODE" ]] || [[ ! -z "$NET2_MODE" ]]; then
	echo "NET_MODE: $NET1_MODE $NET2_MODE" 
	source kvm/net-uni.sh
fi

if [[ ! -z "$PT1_MODE" ]] || [[ ! -z "$PT2_MODE" ]]; then
	echo "PT_MODE: $PT1_MODE $PT2_MODE" 
	source kvm/pci-pt.sh
fi


if [ "x$SOUND_MODE" != "x" ]; then
	source kvm/sound-$SOUND_MODE.sh
fi




CMD="qemu-system-x86_64"
MON_PATH="$VM_PREFIX/$MACHINE/var"
SOCKET=$MACHINE_PATH/var/control

set -e 
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
#CMD="ionice -c 2 -n 3 $CMD"
#CMD="/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[*]} -n -15 -e $CMD"
IFS="$OIFS"
# qemu gets io priority

cat > $MACHINE_PATH/run <<-END
#!/bin/bash
source /srv/kvm/vms/config
cd "$MACHINE_PATH" 
MACHINE='$MACHINE'

function on_begin() {
  	[[ "$USE_HUGEPAGES" = "1" ]] && source $SCRIPT_DIR/../kvm/hugepages.sh
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
	-d unimp,trace:vm_state_notify \
	-D $MACHINE_PATH/var/debug.log \
	-global isa-debugcon.iobase=0x402 \
	-debugcon file:$MACHINE_PATH/var/d.log \
	-boot menu=on \
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
 
	echo "Freeing Hugepages"
 	[[ "$USE_HUGEPAGES" = "1" ]] && source $SCRIPT_DIR/../kvm/hugepages_free.sh

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
