#!/bin/bash

VAR_RUN_DIR="/var/run/qemu"

systemd-unit-for-pid () {
	MACHINE="$1"
  UNIT="$2"
	PID_FILE="$3"

#  systemd-run --no-block \
#	--slice="qemu" \
#	--service-type="exec" \
#	--unit="qemu-${MACHINE/-/__}-$UNIT" \
#	-p PIDFile="$PID_FILE" \
  echo "Test"
}
