source $SCRIPT_DIR/../kvm/lib-hdd.sh

function add_disk () {
	_HDD_NAME="$1"
	eval " V=\$DISK_${_HDD_NAME}_MODE"
	_HDD_MODE=$(valOr "$HDD_MODE" ${V})

	echo "DISK> ADDING $_HDD_NAME MODE: $_HDD_MODE" 1>&2
	add_${_HDD_MODE}_disk $_HDD_NAME
}

function valOr () {
	if [[ -n $2 ]]; then
		echo $2
	else
		echo $1
	fi
}

add_disk clover  
add_disk system 
add_disk data  
add_disk data1
add_disk data2
