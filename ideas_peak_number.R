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
    
    make_option(c("-c", "--column"), type = "double", default = 1, action = "store",
                help = "Which column of file records the value [default %default]"),
    
    make_option(c("-f", "--fdr_thresh"), type = "double", default = 0.05, action = "store",
                help = "The cutoff for fdr to determine true peaks [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]"), 
    
    make_option(c("-l", "--label"), type = "character", default = NULL, action = "store",
                help = "The label for input file (NOT necessary) [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_peak_number.R -i test.bedgraph -c 5 -f 0.01 -s \"\\t\" -H"
  description_message <- "This Script is calculate true peak locus, which is defined by zscaled data with fdr<$fdr_thresh. **Note: the result output directly to screen**"
  
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
    zp = pnorm(-abs(z))
    zpfdr = p.adjust(zp)
    return(zpfdr)
  }
}

# calculation
if (T) {
  # total number
  total_bin <- length(signal)
  
  # peak number
  fdr = get_fdr(signal)
  torf = fdr<fdr_thresh
  n_peaks <- sum(torf)
  
  # percentage
  percent <- n_peaks*100/total_bin
}

# output
if (T) {
  mess <- paste0("Peak_Percentage\t", input, "\t", n_peaks,"/",total_bin,"=",percent,"%\n")
  if (exists("label")) {
    mess <- paste0("Peak_Percentage\t", label, "\t", n_peaks,"/",total_bin,"=",percent,"%\n")
  }
  
  cat(mess)
}


