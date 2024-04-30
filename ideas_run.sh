#!/bin/bash

# usage:
#    bash ideas_run.sh /public/home/yangliu/Project/ENCODE/8.IDEAS/27_markers_ideas/no1/run_S3V2_IDEAS_ENCODE.sh

# options
#    run_S3V2_IDEAS_ENCODE.sh: a single run_S3V2_IDEAS_ENCODE.sh script

script=$1
script_dir=$(dirname ${script})

state_file=${script_dir}/std.out

if [[ ! -f ${state_file} ]]; then
	bash ${script} 1>${script_dir}/std.out 2>${script_dir}/err.out
fi
