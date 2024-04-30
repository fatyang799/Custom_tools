#!/bin/bash

# 识别参数
output_dir=$1
scipt_name=$2

mkdir -p ${output_dir}

# 使用aria2c下载
cat results/2.Experiment_ID_info.csv | grep -v "Experiment_ID" | awk -F"," -v root=${output_dir} '{print "nohup aria2c -d", root, $4, "&"}' > ${scipt_name}
# 使用wget下载
#cat results/2.Experiment_ID_info.csv | grep -v "Experiment_ID" | awk -F"," -v root=${output_dir} '{print "nohup wget -c", $4, "&"}' > ${scipt_name}

cat results/2.Experiment_ID_info.csv | grep -v "Experiment_ID" | awk -F"," -v OFS="\t" '{print $5, $4}' | sed -r "s#https.*/##g" | sort > ${output_dir}/md5.txt
