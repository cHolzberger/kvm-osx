#!/bin/bash

tasks=$( echo -e '{ "execute": "qmp_capabilities" }\n { "execute": "query-cpus" }' | nc localhost 4444 | grep thread_id | cut -d":" -f 2 | xargs echo )

let i=2

echo $tasks
for t in $tasks ; do
let i=$i+1
renice -15 $t
taskset -pc $i $t
echo "setting thread $t to cpu $i"
done
