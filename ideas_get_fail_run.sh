#!/bin/bash

# ideas_get_fail_run.sh

ideas_dir=$1

tmp_dir=/tmp/fatyang/IDEAS/$RANDOM
if [[ -d ${tmp_dir} ]]; then
	rm -rf ${tmp_dir}
fi
mkdir -p ${tmp_dir}


find ${ideas_idr} -name "log.txt" | egrep "IDEAS_output" > ${tmp_dir}/all.txt
cat ${tmp_dir}/all.txt | while read id
do
	egrep "successfully" ${id} > /dev/null
	condition1=$?
	egrep "Done" ${id} > /dev/null
	condition2=$?

	output_dir=$(dirname ${id})
	ls ${output_dir}/*pdf 1>/dev/null 2>&1
	condition3=$?

	if [[ ${condition1} -eq 0 && ${condition2} -eq 0 && ${condition3} -eq 0 ]]; then
		echo ${id} >> ${tmp_dir}/success.txt
	fi
done

if [[ ! -f ${tmp_dir}/success.txt ]]; then
	touch ${tmp_dir}/success.txt
fi

setdiff ${tmp_dir}/all.txt ${tmp_dir}/success.txt
rm -rf ${tmp_dir}

