#!/bin/bash

# start execution
QMP_CMD=(
'{ "execute": "qmp_capabilities" }'
)


QMP_CMD_POST+=(
)

RUN_PRE_BOOT=()

QEMU_CFG=()

source kvm/hugepages.sh 
source kvm/lib-helper.sh
source kvm/common.sh
source kvm/mem-numa.sh 
source kvm/common-$OS.sh
source kvm/common-iommu.sh
source kvm/bios-$BIOS.sh
source kvm/cpu-$CPU_MODEL.sh
source kvm/usb-$USB_MODE.sh
source kvm/gfx-$GFX_MODE.sh
source kvm/hdd-uni.sh
source kvm/teradici.sh 
source kvm/vm-genid.sh


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

if [[ ! -z $FS9P ]]; then
	source kvm/fs-shared.sh
fi

CMD="/opt/qemu/bin/qemu-system-x86_64"
MON_PATH="$MACHINE_VAR"
SOCKET="$MACHINE_VAR/qmp"

set -e 
#CMD="taskset  -c ${USE_CPUS[*]} $CMD"
#CMD="chrt --rr 15 $CMD"
#CMD="ionice -c 2 -n 3 $CMD"
#CMD="/srv/kvm/OSX-KVM/bin/schedtool -a ${USE_CPUS[*]} -n -15 -e $CMD"
IFS="$OIFS"
# qemu gets io priority


echo "Genconfig on $(date)" > $MACHINE_VAR/machine-boot.log

cat > $MACHINE_PATH/bootup.env <<-END
$(declare -p QMP_CMD)
$(declare -p QMP_CMD_POST)
END

cat > $MACHINE_PATH/on-run <<-END
export PATH="$PATH"
exec ${OPEN_FD[@]}

set -o allexport
set -euo pipefail

source /srv/kvm/vms/config
source /srv/kvm/vms/config.host

echo -e "\n\n"
echo "================>> NBD / ISCSI / VIRTIOFSD"
/srv/kvm/OSX-KVM/exec/systemd/run-nbd.sh $MACHINE
/srv/kvm/OSX-KVM/exec/systemd/run-virtiofsd.sh $MACHINE
/srv/kvm/OSX-KVM/exec/systemd/run-iscsi-tgt.sh $MACHINE
echo "<================="



$CMD \
       ${CLOVER_OPTS[@]} \
	${MEMORY_FLAGS[@]} \
	\
	${QEMU_SW[@]} \
	\
        ${QEMU_CFG[@]} \
	\
        ${QEMU_OPTS[@]} \
	\
	\
	-S \
	-pidfile $MON_PATH/pid \
	-writeconfig $MACHINE_VAR/qemu.cfg \
	-D $MACHINE_VAR/debug.log \
	-global isa-debugcon.iobase=0x402 \
	-debugcon file:$MACHINE_VAR/debugcon.log \
	${QEMU_EXTRA_OPTS[@]} \
	-boot menu=on 

END

cat > $MACHINE_PATH/on-exit <<-END
export PATH="$PATH"
MACHINE=$MACHINE

set -o allexport
set -euo pipefail

source /srv/kvm/vms/config
source /srv/kvm/vms/config.host

	${POST_CMD[@]}

	[[ "$USE_HUGEPAGES" = "1" ]] && echo "Freeing Hugepages" && source $SCRIPT_DIR/../kvm/hugepages_free.sh
 if [[ -e $MACHINE_VAR/pid ]]; then
        p="\$(cat $MACHINE_VAR/pid)"
 	if [[ ! -z \$p ]]; then
		if [ -e "/proc/\$p" ]; then
                	kill \$p
        	fi	

		rm $MACHINE_VAR/pid
 	fi
 fi

END

cat > $MACHINE_PATH/run <<-END
#!/bin/bash

set -euo pipefail
source /srv/kvm/vms/config
source /srv/kvm/vms/config.host
cd "$MACHINE_PATH" 
MACHINE='$MACHINE'

function pre_run() {

	${RUN_PRE_BOOT[*]}

	export GFX_AMD_UNBIND="$GFX_AMD_UNBIND"
  	[[ "$USE_HUGEPAGES" = "1" ]] && source $SCRIPT_DIR/../kvm/hugepages.sh
	$(printf "%s" "${PRE_CMD[@]/#/$'\n'}")
}

function on_run() {

	source $MACHINE_PATH/on-run
}

function on_exit() {
 err="$?"

 echo "Exit Code: $err" 
 echo "Done ... cleaing up"
 trap '' EXIT 

 $MACHINE_PATH/on-exit &

 exit $err
}

trap on_exit EXIT 

pre_run
on_run
END

chmod u+x $VM_PREFIX/$MACHINE/run
chmod u+x $VM_PREFIX/$MACHINE/on-run
chmod u+x $VM_PREFIX/$MACHINE/on-exit
CMD=$MACHINE_PATH/run
