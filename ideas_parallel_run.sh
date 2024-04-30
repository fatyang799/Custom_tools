#!/bin/bash

# usage:
#    bash ideas_parallel_run.sh file.txt 10

# options
#    file.txt: a file record the path of run_S3V2_IDEAS_ENCODE.sh

file_list=$1
thread=$2

ideas_run=/share/home/fatyang/Program/Custom_tools/ideas_run.sh

cat ${file_list} | xargs -n1 -i -P${thread} bash ${ideas_run} {}
