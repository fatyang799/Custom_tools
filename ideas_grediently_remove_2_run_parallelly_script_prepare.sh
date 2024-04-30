#!/bin/bash
# Name: ideas_grediently_remove_2_run_parallelly_script_prepare.sh
# Description: 
#	This script will prepare the c.run_parallel.sh script for 
#	IDEAS running parallelly.

######################################################################
####### get parameters #######
# work for ${no}_markers_ideas (26)
no=$1
# root directory (/share/home/fatyang/Project/1.H1_ENCODE/8.Segmentation/1.histone_chip/1.IDEAS/2.grediently_remove_marker)
root=$2
# parallel run script path (/share/home/fatyang/Program/Custom_tools/ideas_parallel_run.sh)
ideas_parallel_run=$3
# submit script path (/share/home/fatyang/Program/Custom_tools/sbatchtask)
submit_script=$4
# thread
thread=$5
# number of total markers (27)
total=$6
# cell line (H1, which was used to find run_S3V2_IDEAS_H1.sh script)
cell=$7
##############################
######################################################################


####### define some settings #######
target_root=${root}/${no}_markers_ideas
####################################


####### run parallelly #######
# a.script_files.txt
if [[ ${no} -eq ${total} ]]; then
	ls ${target_root}/no*/run_S3V2_IDEAS_*.sh > ${target_root}/scripts/a.script_files.txt
else
	ls ${target_root}/remove_*/no*/run_S3V2_IDEAS_*.sh > ${target_root}/scripts/a.script_files.txt
fi

# b.run.sh
echo '#!/bin/bash' > ${target_root}/scripts/b.run.sh
echo "bash ${ideas_parallel_run} ${target_root}/scripts/a.script_files.txt ${thread}" >> ${target_root}/scripts/b.run.sh

# c.run_parallel.sh #
# node 1-4
seq 1 4 | sort -nr | while read node
do
	# job id.
	# total core 56. give 10 core each. so the number of task in each server is 5.
	# to make the resource of server more balenced, the number of task in each server set to 2.

	# the fat node can set more task, the number of task in fat node set to 3.
	if [[ ${node} -eq 4 ]]; then
		echo "bash ${submit_script} ${cell}M${no}_n0${node}_0 ${node} ${target_root}/scripts/b.run.sh 5" > ${target_root}/scripts/c.run_parallel.sh
	fi
	seq 1 3 | while read id
	do
		echo "bash ${submit_script} ${cell}M${no}_n0${node}_${id} ${node} ${target_root}/scripts/b.run.sh 5" >> ${target_root}/scripts/c.run_parallel.sh
	done
done
##############################
