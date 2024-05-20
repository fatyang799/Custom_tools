if True:
	import numpy as np
	import pandas as pd
	import sys

# get filename
if True:
	paras = sys.argv
	tab1 = paras[1]
	order1 = paras[2]
	tab2 = paras[3]
	order2 = paras[4]
	output_tab = paras[5]
	output_loc = paras[6]

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
	# get the raw data
	dat1 = pd.read_csv(tab1, header=None, sep="\t", dtype="str")
	dat2 = pd.read_csv(tab2, header=None, sep="\t", dtype="str")
	# sort the data
	dat1 = dat1.iloc[loc1_index, ]
	dat2 = dat2.iloc[loc2_index, ]
	# get sorted location
	loc = loc1[loc1_index]

# merge the matrix
if True:
	# modify the index (rownames)
	loc1_index.sort()
	loc2_index.sort()
	dat1.set_index(loc1_index, inplace=True)
	dat2.set_index(loc2_index, inplace=True)
	merge_dat = pd.concat([dat1, dat2], axis=1)

# output the matrix
if True:
	merge_dat.to_csv(output_tab, sep="\t", header=False, index=False, na_rep="nan")

# output the sorted location
if True:
	ord = "".join(list(loc))
	with open(output_loc, "w") as f:
		f.write(ord)

