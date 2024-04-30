if True:
	import numpy as np
	import sys

# get filename
if True:
	paras = sys.argv
	# input = "test.npz"
	input1 = paras[1]

# read the data
if True:
	# 1st file
	dat1 = np.load(input1)
	mat1 = dat1["matrix"]

# output
if True:
	shape = mat1.shape
	print("Nrow: " + str(shape[0]) + "\t" + "Ncol: " + str(shape[1]))
