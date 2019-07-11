#!/bin/bash 

echo -e "\n==> Loading $0\n"
if [[ -z "$SSET" ]]; then
	SLOT_COUNT=8
	SSET="1"
fi

function add_vpci() {
	local result_var=$1
	PORT="${2}"
	
	if [[ -z $PORT ]]; then
		"ERROR: PORT not Set!"
		exit -1
	fi
	VB=${VPCI_BUS[0]}
	FN="$MACHINE_PATH/pcie.${SLOT_COUNT}.cfg"
	VPCI_BUS=( ${VPCI_BUS[@]:1} )
	
	vpci_template "$result_var" "$VB" "$SLOT_COUNT" "$PORT" "$FN"
	QEMU_CFG+=( 
		-readconfig $FN 
	)


	eval $result_var="'$result_var.${SLOT_COUNT}'"
	let SLOT_COUNT=SLOT_COUNT+1
}

function vpci_template() {
BS="$1"
VB="$2"
SC="$3"
PORT="$4"
FN="$5"

	SLOT_ADDR=$(echo $VB | cut -d":" -f1)
	SLOT_MULTIFUNCTION=$(echo $VB | cut -d":" -f2)

 echo "VPCI: Config file $FN" >&2
 echo "VPCI: Add Slot#$SC -- port: $PORT -- $VB" >&2  

cat <<END>$FN
[device "$BS.${SC}"]
  driver = "$PORT"
  bus = "pcie.0"
  addr = "${SLOT_ADDR}"
  port = "${SC}"
  chassis = "${SC}"
  multifunction = "${SLOT_MULTIFUNCTION}"
END

}
