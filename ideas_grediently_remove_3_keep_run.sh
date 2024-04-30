#!/bin/bash
# Name: ideas_grediently_remove_3_keep_run.sh
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
# replication number for each remove_Marker (10)
rep=$4
# re-run script (${target_root}/scripts/c.run_parallel.sh)
script=$5
# cell line (H1, which was used to find run_S3V2_IDEAS_H1.sh script)
cell=$6
##############################
######################################################################


####### define some settings #######
if [[ ${no} -eq ${total_marker} ]]; then
	total=${rep}
else
	base=$(expr ${no} + 1)
	total=$(expr ${base} \* ${rep})
fi

target_root=${root}/${no}_markers_ideas
####################################




############################ Uninterrupted monitoring ############################
i=1
while true
do
	####### set conditions to judge whether to re-run the script #######
	# whether all programs end?
	squeue -o "%.18i %.9P %.20j %.8u %.2t %.10M %.6D %R" | egrep "${cell}M${no}_n0[1234]_[0-9]{1,2}" 1>/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		condition1=1
	else
		condition1=0
	fi

	# whether all programs succeed?
	if [[ ${no} -eq ${total_marker} ]]; then
		ls ${target_root}/no*/*_IDEAS_output/*pdf 1>/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			n_success=0
		else
			n_success=$(ls ${target_root}/no*/*_IDEAS_output/*pdf|wc -l)
		fi
	else
		ls ${target_root}/remove_*/no*/*_IDEAS_output/*pdf 1>/dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			n_success=0
		else
			n_success=$(ls ${target_root}/remove_*/no*/*_IDEAS_output/*pdf|wc -l)
		fi
	fi

	if [[ $n_success -eq $total ]]; then
		condition2=0
	else
		condition2=1
	fi
	####################################################################

	##### log #####
	echo "no: $no" > ${target_root}/keep_run.log.txt_${i}
	echo "root: $root" >> ${target_root}/keep_run.log.txt_${i}
	echo "total_marker: $total_marker" >> ${target_root}/keep_run.log.txt_${i}
	echo "rep: $rep" >> ${target_root}/keep_run.log.txt_${i}
	echo "script: $script" >> ${target_root}/keep_run.log.txt_${i}
	echo "cell: $cell" >> ${target_root}/keep_run.log.txt_${i}
	echo "total: $total" >> ${target_root}/keep_run.log.txt_${i}
	echo "n_success: $n_success" >> ${target_root}/keep_run.log.txt_${i}
	echo "condition1: $condition1" >> ${target_root}/keep_run.log.txt_${i}
	echo "condition2: $condition2" >> ${target_root}/keep_run.log.txt_${i}
	###############

	# programs have done
	if [[ $condition1 -ne 0 ]]; then
		# some programs failed
		if [[ $condition2 -ne 0 ]]; then
			# remove the failed std.out file, so that can be re-run again
			if [[ -f /tmp/success.txt ]]; then
				rm /tmp/success.txt
			fi
			if [[ -f /tmp/total.txt ]]; then
				rm /tmp/total.txt
			fi

			if [[ ${no} -eq ${total_marker} ]]; then
				# successful processes
				ls ${target_root}/no*/*_IDEAS_output/*pdf 1>/dev/null 2>&1
				if [[ $? -eq 0 ]]; then
					ls ${target_root}/no*/*_IDEAS_output/*pdf | xargs dirname | xargs dirname | while read id
					do
						egrep -i "done|success" ${id}/*/log.txt 1>/dev/null 2>&1
						if [[ $? -eq 0 ]]; then
							echo ${id} | egrep -o "no[0-9]{1,2}" >> /tmp/success.txt
						fi
					done
				else
					touch /tmp/success.txt
				fi
				# total processes
				ls -d ${target_root}/no* | egrep -o "no[0-9]{1,2}" > /tmp/total.txt
			else
				# successful processes
				ls ${target_root}/remove_*/no*/*_IDEAS_output/*pdf 1>/dev/null 2>&1
				if [[ $? -eq 0 ]]; then
					ls ${target_root}/remove_*/no*/*_IDEAS_output/*pdf | xargs dirname | xargs dirname | while read id
					do
						egrep -i "done|success" ${id}/*/log.txt 1>/dev/null 2>&1
						if [[ $? -eq 0 ]]; then
							echo ${id} | egrep -o "remove_.{5,15}/no[0-9]{1,2}" >> /tmp/success.txt
						fi
					done
				else
					touch /tmp/success.txt
				fi
				# total processes
				ls -d ${target_root}/remove_*/no* | egrep -o "remove_.{5,15}/no[0-9]{1,2}" > /tmp/total.txt
			fi
			# test start #
			echo "success.txt:" >> ${target_root}/keep_run.log.txt_${i}
			cat /tmp/success.txt >> ${target_root}/keep_run.log.txt_${i}
			echo "to_rm_files.txt:" >> ${target_root}/keep_run.log.txt_${i}
			sort /tmp/total.txt /tmp/success.txt /tmp/success.txt | uniq -u | xargs -n1 -i echo {} >> ${target_root}/keep_run.log.txt_${i}
			((i++))
			# test end #

			sort /tmp/total.txt /tmp/success.txt /tmp/success.txt | uniq -u | xargs -n1 -i rm ${target_root}/{}/{err.out,std.out} 1>/dev/null 2>&1
			# re-run the script
			rm /tmp/{total.txt,success.txt}
			bash ${script}
		else
			# all programs have done successfully, then break loop
			rm /tmp/{total.txt,success.txt}
			break
		fi
	fi

	sleep 300
done
##################################################################################
