#!/bin/bash

# 将bed文件格式数据转为200的bin size格式
input=$1
output=$2

awk -F "\t" -v OFS="\t" '{diff=$3-$2; if(diff!=200){a=$2; for(i=1; i <= diff/200; i++){print $1,a,a+200,$4;a=a+200}} else {print $1,$2,$3,$4}}' ${input} > ${output}
