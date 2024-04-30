# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  suppressPackageStartupMessages(library(data.table))
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = NULL, action = "store",
                help = "The output file [default %default]"),
    
    make_option(c("-c", "--column_number"), type = "integer", default = 1, action = "store",
                help = "Which column of file record the value in input file [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character.Note: if the character has '\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_non-0_dat_output.R -i ENCODE_cells.state -o H1.non0.txt -c 5 -s ' ' -H"
  description_message <- "This Script is to select non-0 data."
  
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

# read data
if (T) {
  dat <- fread(input, header = header, sep = sep, data.table = F)[, column_number]
}

# get non-0 dat
if (T) {
  non_0 <- dat[dat!=min(dat)]
}

# output
if (T) {
  data.table::fwrite(as.data.frame(non_0), file = output, row.names = F, col.names = F)
}

