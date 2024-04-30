args <- commandArgs(trailingOnly=TRUE)
a=args[1]
b=args[2]
c=as.numeric(args[3])

print(a)
print(b)
print(c)
print(is.na(c))
print(args)

# Rscript test.R a 
# Rscript test.R a 2
# Rscript test.R a 2 2


