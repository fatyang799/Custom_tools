#!/bin/bash

# chromhmm_run_ideas_format.sh

BinarizeDat_dir=$1
results_dir=$2
log_dir=$3
location=$4
chromosomelengthfile=$5
n_state=$6
assembly=hg38

if [[ -z ${BinarizeDat_dir} ]]; then
	echo "Usage:"
	echo -e "\t\$1: BinarizeDat_dir"
	echo -e "\t\$2: results_dir"
	echo -e "\t\$3: log_dir"
	echo -e "\t\$4: chr_windows directory"
	echo -e "\t\$5: chromosomelengthfile"
	echo -e "\t\$6: n_state"
	exit 100
fi

if [[ ! -f ${results_dir}/${n_state}_encode_chromhmm_segments.bed.gz ]]; then
	# 1.chromhmm
	std=${log_dir}/1.chromHMM.std
	err=${log_dir}/1.chromHMM.err
	java -mx8000M -jar $HOME/Program/chromHMM/ChromHMM/ChromHMM.jar LearnModel \
		-b 200 -color 255,0,0 -d 0.0001 -gzip \
		-i encode_chromhmm -init information \
		-l ${chromosomelengthfile} -noautoopen -nobrowser -noenrich \
		-r 200 -s 999 \
		${BinarizeDat_dir} \
		${results_dir} \
		${n_state} ${assembly} 1>${std} 2>${err}
	if [[ $? -ne 0 ]]; then
		id=$(dirname ${results_dir})
		echo "ChromHMM error for ${id}"
		exit 100
	fi

	# 2.转为标准200 binSize bed文件格式
	std=${log_dir}/2.chromhmm_format_as_ideas.std
	err=${log_dir}/2.chromhmm_format_as_ideas.err
	ls ${results_dir}/*bed.gz | xargs -n1 -i -P 5 chromhmm_format_as_ideas {} ${location} 1>${std} 2>${err}
	if [[ $? -ne 0 ]]; then
		id=$(dirname ${results_dir})
		echo "chromhmm_format_as_ideas error for ${id}"
		exit 100
	fi

	# 3.合并文件作为标准IDEAS的输出格式
	std=${log_dir}/3.chromhmm_merge_as_ideas.std
	err=${log_dir}/3.chromhmm_merge_as_ideas.err
	chromhmm_merge_as_ideas ${results_dir} "H1 H9 IMR90" ${results_dir}/${n_state}_encode_chromhmm_segments.bed 1>${std} 2>${err}
	pigz ${results_dir}/${n_state}_encode_chromhmm_segments.bed

	if [[ $? -ne 0 ]]; then
		id=$(dirname ${results_dir})
		echo "chromhmm_merge_as_ideas error for ${id}"
		exit 100
	fi

	echo "H1 H9 IMR90" | xargs -n1 | xargs -n1 -i rm ${results_dir}/{}_${n_state}_encode_chromhmm_segments.bed

	echo "The chromhmm has done, and the outputs have been transfer to the format of IDEAS for:"
	echo -e "${n_state}\t${results_dir}"	
else
	echo "The output file have exist:"
	echo "${results_dir}/${n_state}_encode_chromhmm_segments.bed.gz"
	exit
fi
