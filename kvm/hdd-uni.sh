source $SCRIPT_DIR/../kvm/lib-hdd.sh

function add_disk () {
	_HDD_NAME="$1"
	eval " V=\$HDD_${_HDD_NAME}_MODE"
	_HDD_MODE=$(valOr "$HDD_MODE" "$V")
	echo -e "\n $V or $HDD_MODE"
	add_${_HDD_MODE}_disk $_HDD_NAME
}

function valOr () {
	if [[ -z $2 ]]; then
		echo $1
	else
		echo $2
	fi
}

add_disk clover  
add_disk system 
add_disk data  
add_disk data1
add_disk data2
