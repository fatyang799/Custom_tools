#!/bin/bash

id=$1
chr=$2
loca_file=$3

rand=$RANDOM
tmp=$HOME/tmp/chromhmm2ideas/${rand}
mkdir -p ${tmp}

egrep "^${chr}\s" ${id} > ${id}.${chr}
n1=$(wc -l ${id}.${chr} | cut -d " " -f1)
n2=$(wc -l ${loca_file} | cut -d " " -f1)
if [[ $n1 -eq $n2 ]]; then
	paste ${id}.${chr} ${loca_file} | awk -F "\t" -v OFS="\t" '{print $5,$6,$7,$4}' > ${tmp}/${rand}.txt
	mv ${tmp}/${rand}.txt ${id}.${chr}
else
	echo "the ${chr} of ${id} raise error"
	exit 1
fi

rm -rf ${tmp}
