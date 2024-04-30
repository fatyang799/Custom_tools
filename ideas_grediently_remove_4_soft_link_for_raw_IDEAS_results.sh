#!/bin/bash
# Name: ideas_grediently_remove_4_soft_link_for_raw_IDEAS_results.sh
# Description: 
#	This script can create soft links to link the IDEAS output file
#	including ${id_name}.state and ${id_name}.para to target directory.

######################################################################
####### get parameters #######
# work for ${no}_markers_ideas (26)
no=$1
# root directory (/share/home/fatyang/Project/1.H1_ENCODE/8.Segmentation/1.histone_chip/1.IDEAS/2.grediently_remove_marker)
root=$2
# number of total markers (27)
total_marker=$3
# replication number for each remove_Marker (10)
rep=$4
# re-run script (H1_27_Markers)
id_name=$5
##############################
######################################################################


####### define some settings #######
# source directory
base=$(expr ${no} + 1)
# related directory definition
target=${root}/${no}_markers_ideas
# related file definition
meta=${target}/${base}_metadata.txt
####################################



####### create soft link for ${id_name}.state and ${id_name}.para #######
if [[ ${no} -eq ${total_marker} ]]; then
	seq 1 ${rep} | while read number
	do
		# raw ${id_name}.state and ${id_name}.para path
		state=${target}/no${number}/${id_name}_IDEAS_output/${id_name}.state
	    para=${target}/no${number}/${id_name}_IDEAS_output/${id_name}.para

	    # target root path
		path_state=${target}/1.all_state_summary
		if [[ ! -d ${path_state} ]]; then
			mkdir -p ${path_state}
		fi
		path_para=${target}/2.all_para_summary/1.raw
		if [[ ! -d ${path_para} ]]; then
			mkdir -p ${path_para}
		fi

	    # soft link
	    ln -s ${state} ${path_state}/no${number}.state
	    ln -s ${para} ${path_para}/no${number}.para
	done
else
	cut -f2 ${meta}|while read marker
	do
	    # target root path
		path_state=${target}/1.all_state_summary/remove_${marker}
		if [[ ! -d ${path_state} ]]; then
			mkdir -p ${path_state}
		fi
		path_para=${target}/2.all_para_summary/remove_${marker}/1.raw
		if [[ ! -d ${path_para} ]]; then
			mkdir -p ${path_para}
		fi
		# soft link
		seq 1 ${rep} | while read number
		do
			# raw ${id_name}.state and ${id_name}.para path
			state=${target}/remove_${marker}/no${number}/${id_name}_IDEAS_output/${id_name}.state
		    para=${target}/remove_${marker}/no${number}/${id_name}_IDEAS_output/${id_name}.para

		    # soft link
		    ln -s ${state} ${path_state}/no${number}.state
			ln -s ${para} ${path_para}/no${number}.para
		done
	done
fi
#########################################################################
