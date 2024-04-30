#!/bin/bash
# Name: ideas_grediently_remove_1_prepare_meta_script.sh
# Description: 
#	This script will prepare the metadata.txt and run_S3V2_IDEAS_${cell}.sh
#	for IDEAS running.

######################################################################
####### get parameters #######
# work for ${no}_markers_ideas (26)
no=$1
# removed marker based on ${no+1}_markers_ideas (H4K91ac)
remove_M=$2
# cell line (H1, which was used to find run_S3V2_IDEAS_H1.sh script)
cell=$3
# root directory (/share/home/fatyang/Project/1.H1_ENCODE/8.Segmentation/1.histone_chip/1.IDEAS/2.grediently_remove_marker)
root=$4
# normalized data directory (/share/home/fatyang/Project/1.H1_ENCODE/7.Normalization/1.histone_chip/3.s3norm/1.withoutCT/2.normalization)
raw_input=$5
# number of total markers (27)
total=$6
# replication number for each remove_Marker (10)
rep=$7
##############################
######################################################################

####### define some settings #######
# source directory
base=$(expr ${no} + 1)
# related directory definition
target=${root}/${no}_markers_ideas
source=${root}/${base}_markers_ideas
# script template
raw_script=${root}/${total}_markers_ideas/no1/run_S3V2_IDEAS_${cell}.sh
####################################


####### metadata file #######
if [[ ${base} -eq ${total} ]];then
	meta=${source}/metadata.txt
else
	meta_n=$(expr $base + 1)
	meta=${source}/${meta_n}_metadata.txt
fi
grep -v "${remove_M}" ${meta} > ${target}/${base}_metadata.txt
#############################


####### soft link and run script #######
cut -f2 ${target}/${base}_metadata.txt | while read marker
do
	# metadata
	if [[ ! -d ${target}/remove_${marker} ]]; then
		mkdir -p ${target}/remove_${marker}
	fi
	grep -v ${marker} ${target}/${base}_metadata.txt > ${target}/remove_${marker}/metadata.txt

	# script
	seq 1 ${rep} | while read time
	do
		# input file
		if [[ ! -d ${target}/remove_${marker}/no${time} ]]; then
			mkdir -p ${target}/remove_${marker}/no${time}
		fi
		
		ls ${target}/remove_${marker}/no${time}/{*IDEAS_input_NB,windows.bed,windowsNoBlack.noid.bed,windowsNoBlack.withid.bed} 1>/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			rm -rf ${target}/remove_${marker}/no${time}/*IDEAS_input_NB ${target}/remove_${marker}/no${time}/{windows.bed,windowsNoBlack.noid.bed,windowsNoBlack.withid.bed} 1>/dev/null 2>&1
			ln -s ${raw_input}/{*IDEAS_input_NB,windows.bed,windowsNoBlack.noid.bed,windowsNoBlack.withid.bed} ${target}/remove_${marker}/no${time}/
		fi

		# edit
		output=${target}/remove_${marker}/no${time}/
		meta_path=${target}/remove_${marker}/metadata.txt
		sed "s@${root}/${total}_markers_ideas/no1/@${output}@g" ${raw_script} > /tmp/test.txt
		sed "s@${root}/${total}_markers_ideas/metadata.txt@${meta_path}@g" /tmp/test.txt > ${target}/remove_${marker}/no${time}/run_S3V2_IDEAS_${cell}.sh
	done
done

if [[ -f /tmp/test.txt ]]; then
	rm /tmp/test.txt
fi

########################################
