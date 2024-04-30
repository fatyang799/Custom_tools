#!/bin/bash

# 识别参数
output_dir=$1
scipt_name=$2

mkdir -p ${output_dir}

# 使用aria2c下载
cat results/*csv | grep -v "Experiment_ID" | awk -F"," -v root=${output_dir} '{print "nohup aria2c -d", root, "-o", $3, $4, "&"}' > ${scipt_name}
# 使用wget下载
#cat results/*csv | grep -v "Experiment_ID" | awk -F"," -v root=${output_dir} '{print "nohup wget -c -O", root"/"$3, $4, "&"}' > ${scipt_name}

cat results/*csv | grep -v "Experiment_ID" | awk -F"," -v OFS="\t" '{print $5, $3}' | sort > ${output_dir}/md5.txt

