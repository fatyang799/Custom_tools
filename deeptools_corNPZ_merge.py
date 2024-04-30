if True:
	import numpy as np
	import pandas as pd
	import sys

# get filename
if True:
	paras = sys.argv
	npz1 = paras[1]
	order1 = paras[2]
	npz2 = paras[3]
	order2 = paras[4]
	output_npz = paras[5]
	output_order = paras[6]

# get the order
if True:
	def get_array(file):
		with open(file, "r") as f:
			cont = f.readlines()
		dat = np.array(cont)
		return(dat)
	loc1 = get_array(order1)
	loc2 = get_array(order2)
	loc1_index = np.argsort(loc1, axis=0)
	loc2_index = np.argsort(loc2, axis=0)

# get the data
if True:
	# 1st file
	dat1 = np.load(npz1)
	mat1 = dat1["matrix"]
	lab1 = dat1["labels"]
	mat1 = mat1[loc1_index, ]
	# 2nd file
	dat2 = np.load(npz2)
	mat2 = dat2["matrix"]
	lab2 = dat2["labels"]
	mat2 = mat2[loc2_index, ]

# merge the matrix
if True:
	merge_lab = np.concatenate([lab1, lab2], axis=0)
	merge_mat = np.concatenate([mat1, mat2], axis=1)

# output the matrix
if True:
	f = open(output_npz, "wb")
	np.savez_compressed(f, matrix=merge_mat, labels=merge_lab)
	f.close()

# output the index
if True:
	loc1 = loc1[loc1_index]
	ord = "#'chr'_'start'_'end'\n" + "".join(list(loc1))
	with open(output_order, "w") as f:
		f.write(ord)
