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
    
    make_option(c("-l", "--label"), type = "character", default = NULL, action = "store",
                help = "The label for input file [default: input file name]"),
    
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
  usage_message <- "Rscript qc_percentage_0.R -i ENCODE_cells.state -l H1 -c 5 -s ' ' -H"
  description_message <- "This Script is to plot barplot."
  
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

# test dat
if (F) {
  input <- "ENCODE_cells.state"
  column_number <- 5
  sep <- " "
  header <- T
}

# read data
if (T) {
  dat <- fread(input, header = header, sep = sep, data.table = F)[, column_number]
}

# statistics
if (T) {
  total=length(dat)
  n_0 <- sum(dat==min(dat))
  percentage <- 100*n_0/total
}

# message
if (T) {
  # label
  message <- ifelse(exists("label"), 
                    paste("Min_value_Percentage", label, percentage, sep = "\t"),
                    paste("Min_value_Percentage", basename(input), percentage, sep = "\t"))
  message <- paste0(message, "\n")
  cat(message)
}
