# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(optparse)
  library(stringr)
}

# get arguments
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = NULL, action = "store",
                help = "The input file")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_get_mean_signal_track.R -i ATAC-seq.H1.signal.txt -o H1_m1.ATAC-seq.S3V2.bedgraph.NBP.txt"
  description_message <- "This Script is to merge IDEAS output and get average signal."
  
  option_object <- OptionParser(
    usage = paste0("usage: %prog [options]\n\t",usage_message,"\n"),
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
  input <- "H2BK120ac.H9.signal.txt"
}

# read the data
if (T) {
  print(paste0(input, " begin"))
  
  dat <- data.table::fread(input, header = F, sep = "\t", data.table = F)
  dat <- sapply(dat, as.numeric)
}

# get average signal
if (T) {
  signal <- rowMeans(dat)
}

# output
if (T) {
  write.table(signal, file = output, quote=F, col.names=F, row.names=F, sep='\t')
  print(paste0(input, " done"))
}


