#!/bin/bash

state1=$1
state2=$2
col1=$3
col2=$4
output=$5


rand=$RANDOM
tmp=/tmp/fatyang_${rand}
if [[ -d ${tmp} ]]; then
	rm -rf ${tmp}
fi
mkdir -p ${tmp}


cut -d " " -f ${col1} ${state1} > ${tmp}/state1.state
cut -d " " -f ${col2} ${state2} > ${tmp}/state2.state

echo -e "Number\tAll2RM" > ${output}
paste -d "_" ${tmp}/state1.state ${tmp}/state2.state | \
	sort | \
	uniq -c | \
	grep -v "m1" | \
	sed "s/^\s*//" | \
	sort -nr | \
	sed "s/ /\t/g" >> ${output}

rm -rf ${tmp}
