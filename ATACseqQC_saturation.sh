#!/bin/bash

# ATACseqQC_saturation.sh
input_bam=$1
label=$2
output_dir=$3
# SE or PE
type=$4
# Rscripts: PATH/TO/ATACseqQC_saturation.R
Rscripts=$5

prefix=$(echo ${input_bam} | xargs -n1 basename)
script=$HOME/Program/Custom_tools/shuf_bam_call_peaks_${type}

# shuf bam within chr1 to call peaks
bash ${script} ${input_bam} ${output_dir}

# ATACseqQC R
Rscript ${Rscripts} ${output_dir}/chr1_${prefix} ${label} ${output_dir} ${type}

# remove tmp file
rm -rf ${output_dir}/chr1* ${output_dir}/reads*
