# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "Target.txt", action = "store",
                help = "The input file [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "Output.txt", action = "store",
                help = "The output file. [default %default]"),
    
    make_option(c("-r", "--row_file"), type = "character", default = "row_number.txt", action = "store",
                help = "Selected row number for input file [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript select_target_row_dat.R -i input.txt -o output.txt -r row.file"
  description_message <- "This Script is to select target row dat"
  
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
  input <- "3.peak_with_motif.stat.format"
  output <- "test.txt"
  row_file <- "tmp.txt"
}

# read and select the data
if (T) {
  dat <- data.table::fread(input, header = F, sep = "\t", data.table = F, fill = T)
  
  # get row number
  if (T) {
    row <- data.table::fread(row_file, header = F, data.table = F)[,1]
    row <- as.numeric(row)
  }
  
  dat <- dat[row, ]
}

# output
if (T) {
  write.table(dat, file = output, quote = F, sep = "\t", col.names = F, row.names = F)
}

