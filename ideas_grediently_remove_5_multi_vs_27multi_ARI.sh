#!/bin/bash
# Name: ideas_grediently_remove_5_multi_vs_27multi_ARI.sh
# Description: 
#	This script will ensure that the program run successfully.
#	If the program run failed, it will automatically re-run again.

######################################################################
####### get parameters #######
# work for ${no}_markers_ideas (26)
no=$1
# root directory (/share/home/fatyang/Project/1.H1_ENCODE/8.Segmentation/1.histone_chip/1.IDEAS/2.grediently_remove_marker)
root=$2
# number of total markers (27)
total_marker=$3
# re-run script (/share/home/fatyang/Program/Custom_tools/ideas_ARI_between_two_list_files.R)
R_script=$4
##############################
######################################################################


####### define some settings #######
# only work for ${no}<${total_marker}
if [[ ${no} -eq ${total_marker} ]]; then
	echo "${total_marker} Markers states are reference, do not need to be compared."
	exit 100
fi
# related directory definition
target_root=${root}/${no}_markers_ideas
M_total_root=${root}/${total_marker}_markers_ideas
output=${target_root}/4.multi_vs_multi/1.table
####################################


############################ paired ARI calculation between total_Marker_rep and removed_Marker_rep ############################
# mkdir 
if [[ ! -d ${output} ]]; then
	mkdir -p ${output}
fi


# get all state file path
ls ${M_total_root}/1.all_state_summary/no*state > ${output}/file1.txt
ls ${target_root}/1.all_state_summary/remove_*/no*state > ${output}/file2.txt

# get label for script
for id in file1 file2
do
	M_number=$(egrep -o "[0-9]{1,2}_markers_ideas" ${output}/${id}.txt | sort -u | egrep -o "[0-9]{1,2}" | xargs -i echo "{}M")
	egrep -o "no[0-9]{1,2}" ${output}/${id}.txt | xargs -n1 -i echo "${M_number}_{}" > ${output}/${id}.name1
	if [[ $id == file2 ]]; then
		egrep -o "H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?" ${output}/${id}.txt | xargs -n1 -i echo "_{}" > ${output}/${id}.name2
	else
		touch ${output}/${id}.name2
	fi
	paste ${output}/${id}.name1 ${output}/${id}.name2 | sed "s/\t//g" > ${output}/${id}.name
	rm ${output}/${id}.name1 ${output}/${id}.name2
done

# run paired ARI calculation
Rscript ${R_script} \
	-a ${output}/file1.txt -b ${output}/file2.txt \
	-c ${output}/file1.name -d ${output}/file2.name \
	-o ${output}/${total_marker}_${no}_RI_multi_vs_multi.xls \
	-O ${output}/${total_marker}_${no}_ARI_multi_vs_multi.xls
