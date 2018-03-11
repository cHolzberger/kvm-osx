function join_arr() {
	arr=($@)
	bar=$(printf ",%s" "${arr[@]}")
	bar=${bar:1}
	echo $bar
}
