# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "test.bedgraph", action = "store",
                help = "The input file [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-c", "--column"), type = "double", default = 1, action = "store",
                help = "Which column of file records the value [default %default]"),
    
    make_option(c("-f", "--fdr_thresh"), type = "double", default = 0.05, action = "store",
                help = "The cutoff for fdr to determine true peaks [default %default]"),
    
    make_option(c("-l", "--l_index"), type = "logical", default = F, action = "store_true",
                help = "Whether output location index, instead of 0/1 [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = NULL, action = "store",
                help = "The output file for peaks record, in which 1 represents peak and 0 indicates background [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_get_peaks.R -i test.bedgraph -c 1 -f 0.05 -s \"\\t\" -H -o test.txt"
  description_message <- "This Script is calculate true peak locus, which is defined by zscaled data with fdr<$fdr_thresh."
  
  option_object <- OptionParser(
    usage = paste0("usage:  Rscript %prog [options]\n\t",usage_message,"\n"),
    option_list = option_list,
    add_help_option = TRUE,
    description = description_message
  )
  args <- parse_args(
    option_object,
    args = commandArgs(trailingOnly = TRUE),
    print_help_and_exit = T
  )
}

# Assign parameters
if (T) {
  for (i in 1:length(args)) {
    x <- args[[i]]
    name <- names(args)[i]
    assign(name,x)
  }
  rm(name,x,i)
}

# test data
if (F) {
  input <- "test.bedgraph"
  header <- F
  sep <- "\t"
  column <- 1
  fdr_thresh <- 0.05
  output <- "stat_torf.txt"
  
  l_index <- T
}

# read data
if (T) {
  signal <- data.table::fread(input, header = header, sep = sep, data.table = F)[, column]
}

# custom function
if (T) {
  ### get z
  get_z = function(x){
    x_notop = x[x<=quantile(x[x>min(x)], 0.95)]
    xz = (x - mean(x_notop)) / sd(x_notop)
    return(xz)
  }
  ### get fdr
  get_fdr = function(x){
    z = get_z(x)
    zp = pnorm(z, lower.tail = F)
    zpfdr = p.adjust(zp)
    return(zpfdr)
  }
}

# calculation
if (T) {
  # peak number
  fdr = get_fdr(signal)
  torf = fdr<fdr_thresh
}

# 0/1 or location index
if (l_index) {
  torf <- which(torf)
}
if (! l_index) {
  torf <- as.numeric(torf)
}

# output
if (T) {
  write.table(torf, file = output, quote = F, sep = "\t", col.names = F, row.names = F)
}


