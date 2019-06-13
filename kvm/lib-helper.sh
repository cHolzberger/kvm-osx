#!/bin/bash 


function join_arr() {
	IFS=",$IFS";
	arr=($@)
	bar=$(printf "%s" "${arr[*]}")
	bar=${bar:1}
	echo $bara
	IFS=${IFS:1}
}

