#!/bin/bash

# usage:
#    bash ideas_qsub.sh file.txt 2 2 3

# options
#    file.txt: a file record the path of run_S3V2_IDEAS_ENCODE.sh
#    start: from which node start
#    end: to which node end
#    thread: in each node, how many programs run parallelly


file_list=$1
start=$2
end=$3
thread=$4
script=/public/home/yangliu/Program/Custom_tools/ideas_parallel_run.sh

seq ${start} ${end} | while read id
do
    echo "bash ${script} ${file_list} ${thread}" | qsub -V -cwd -S /bin/bash -now y -pe mpi 5 -N node${id} -q all.q@comput${id}
done
