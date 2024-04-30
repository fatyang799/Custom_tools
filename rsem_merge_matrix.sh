#!/bin/bash

# @Author: Liuyang
# @Date:   2023-03-16 15:17:22
# @Last Modified by:   86766
# @Last Modified time: 2023-03-16 15:29:17

file_list=$1
# data_type can be "expected_count", "TPM" or "FPKM". If type of data is tx, then data_type can additional be "IsoPct"
type=$2
output=$3


project_id=$RANDOM

if [[ ! -d /tmp/fatyang/${project_id} ]]; then
	mkdir -p /tmp/fatyang/${project_id}
fi

# get the id
temp=$(head -n1 ${file_list})
awk -F"\t" -v OFS="\t" '{print $1,$2,$3}' ${temp} > /tmp/fatyang/${project_id}/id.txt

# get the target column value
if [[ $type == "expected_count" ]]; then
	target=5
elif [[ $type == "TPM" ]]; then
	target=6
elif [[ $type == "FPKM" ]]; then
	target=7
elif [[ $type == "IsoPct" ]]; then
	target=8
fi

# get attributions
n=$(cat ${file_list} | wc -l)
step=$(head -n1 ${temp} | awk -F"\t" '{print NF}')
ncol=$(expr ${n} \* ${step})

# get content
if [[ -f /tmp/fatyang/${project_id}/content_file.txt ]]; then
	rm /tmp/fatyang/${project_id}/content_file.txt
fi

i=1
files=$(cat ${file_list})
seq ${target} ${step} ${ncol} | while read target_col
do
	fid=$(cat ${file_list} | xargs basename -a | head -n ${i} | tail -n 1)
	echo "/tmp/fatyang/${project_id}/${fid}.txt" >> /tmp/fatyang/${project_id}/content_file.txt
	(echo "${fid}"; paste ${files} | cut -f "${target_col}" | tail -n+2) > /tmp/fatyang/${project_id}/${fid}.txt
	((i++))
done

# merge the id and content
files=$(cat /tmp/fatyang/${project_id}/content_file.txt)
paste /tmp/fatyang/${project_id}/id.txt ${files} > ${output}

# remove redundent files
rm -rf /tmp/fatyang/${project_id}
