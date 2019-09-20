#!/bin/bash 


function join_arr() {
	IFS=",$IFS";
	arr=($@)
	bar=$(printf "%s" "${arr[*]}")
	bar=${bar:1}
	echo $bara
	IFS=${IFS:1}
}

function contains() {
	_F="$1"
	_L="$2"

	grep -Fxq -- $_F $_L
}
