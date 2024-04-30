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
	lab2 = [x.strip() for x in dat2]

# output
if True:
	f = open(output, "wb")
	np.savez_compressed(f, matrix=mat1, labels=lab2)
	f.close()

