#!/bin/bash

if [[ ! -z "$PSET" ]]; then
QEMU_SW+=(
# -device pcie-root-port,port=0x8,chassis=1,id=xpci.1,bus=pcie.0,multifunction=on,addr=0x2 
# -device pcie-pci-bridge,id=xpci.2,bus=xpci.1,addr=0x0 
)

PSET=1
fi

function add_io3420_port() {
	NAME=$1

	QEMU_SW+=(
	-device ioh3420,id=$NAME.1,chassis=1$CHASSIS_COUNT,addr=0x1$CHASSIS_COUNT.0,bus=pcie.0
	)
	let CHASSIS_COUNT=$CHASSIS_COUNT+1
}

if [[ -z "$CHASSIS_COUNT" ]]; then
	CHASSIS_COUNT=1
fi
function add_root_port() {
	NAME=$1

	QEMU_SW+=(
    	-device pcie-root-port,port=0x1$CHASSIS_COUNT,chassis=1$CHASSIS_COUNT,id=$NAME.1,bus=pcie.0,addr=0x2.0x$CHASSIS_COUNT
	)

	let CHASSIS_COUNT=$CHASSIS_COUNT+1
#    -device pcie-root-port,port=0x11,chassis=13,id=$NAME.3,bus=pcie.0,addr=$BASE.0x1 
#    -device pcie-root-port,port=0x12,chassis=14,id=$NAME.4,bus=pcie.0,addr=$BASE.0x2 
#    -device pcie-root-port,port=0x13,chassis=15,id=$NAME.5,bus=pcie.0,addr=$BASE.0x3 
#    -device pcie-root-port,port=0x14,chassis=16,id=$NAME.6,bus=pcie.0,addr=$BASE.0x4 
#    -device pcie-root-port,port=0x15,chassis=17,id=$NAME.7,bus=pcie.0,addr=$BASE.0x5 
#    -device pcie-root-port,port=0x16,chassis=18,id=$NAME.8,bus=pcie.0,addr=$BASE.0x6 
#    -device pcie-root-port,port=0x17,chassis=19,id=$NAME.9,bus=pcie.0,addr=$BASE.0x7 
}
#    -device pcie-pci-bridge,id=$NAME.2,bus=$NAME.1,addr=0x0 

if [[ -z "$PCI_CURRENT_SLOT" ]]; then
	PCI_CURRENT_SLOT=1
fi

function add_pciept_dev() {
        HOST_PCIPORT=$1
        VM_BUS=$2
        VM_ADDR=$3

        [[ -z "$HOST_PCIPORT" ]] && echo "PCIPORT: empty" >&2  && return
                if [[ -z "$VM_ADDR" ]]; then
		VM_ADDR=0x0
	fi
	
	find /sys/bus/pci/devices/$HOST_PCIPORT/ -wholename \*/block/\*/device | while read dev; do
		echo "\tUnplugging $dev"
		echo -n 1 > $dev/delete
	done
        sleep 2
	RUN_PRE_BOOT+=( 
		vfio-bind $HOST_PCIPORT
  )
	if [[ -z "$VM_BUS" ]];then
		VM_BUS="pt_${PCI_CURRENT_SLOT}"
		add_io3420_port $VM_BUS
		VM_BUS="$VM_BUS.1"
 	       let PCI_CURRENT_SLOT=$PCI_CURRENT_SLOT+1
		let CHASSIS_COUNT=$CHASSIS_COUNT+1

	fi

        QEMU_OPTS+=(-device vfio-pci,host=$HOST_PCIPORT,bus=$VM_BUS,addr=0x0,rombar=1,romfile="")
#rombar=0
}

