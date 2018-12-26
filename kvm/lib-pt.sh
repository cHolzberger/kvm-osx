#!/bin/bash

if [[ ! -z "$PSET" ]]; then
QEMU_SW+=(
 -device pcie-root-port,port=0x8,chassis=1,id=xpci.1,bus=pcie.0,multifunction=on,addr=0x2 
 -device pcie-pci-bridge,id=xpci.2,bus=xpci.1,addr=0x0 
)

PSET=1
fi

function add_io3420_port() {
	NAME=$1

	QEMU_SW+=(
	-device ioh3420,id=$NAME.1,chassis=0,slot=0,bus=pcie.0
	)
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
