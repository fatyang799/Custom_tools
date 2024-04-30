#!/bin/bash

custom_dir=/share/home/fatyang/Program/Custom_tools

bash $custom_dir/ideas_get_fail_run.sh . | xargs -n1 dirname | xargs dirname | while read id
do
	rm -rf ${id}/ENCODE_cells_IDEAS_output
	rm -rf ${id}/bin
	rm -rf ${id}/data
	rm ${id}/ENCODE_cells.*
	rm ${id}/*out
done
