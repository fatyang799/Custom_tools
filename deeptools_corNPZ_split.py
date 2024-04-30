if True:
	import numpy as np
	import sys

# get filename
if True:
	paras = sys.argv
	# input = "test.npz"
	input1 = paras[1]
	input2 = paras[2]
	output = paras[3]

# read the data
if True:
	# 1st file
	dat1 = np.load(input1)
	mat1 = dat1["matrix"]
	lab1 = dat1["labels"]
	# 2nd file
	with open(input2, "r") as f:
		dat2 = f.readlines()
	dat2 = [x.strip() for x in dat2]

# select the matrix
if True:
	torf = [x in dat2 for x in lab1]
	lab2 = lab1[torf]
	mat2 = mat1[:, torf]

# output
if True:
	f = open(output, "wb")
	np.savez_compressed(f, matrix=mat2, labels=lab2)
	f.close()

