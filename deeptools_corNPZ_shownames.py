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
	dat1 = np.load(input1)
	lab1 = dat1["labels"]

# output
if True:
	for x in lab1:
		print(x.strip())

