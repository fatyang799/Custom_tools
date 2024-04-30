

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
    make_option(c("-r", "--reference"), type = "character", default = NULL, action = "store",
                help = "The reference of ideas state file [default %default]"),
    
    make_option(c("-c", "--compare"), type = "character", default = NULL, action = "store",
                help = "A compared state file [default %default]"),
    
    make_option(c("-R", "--column_ref"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in reference file [default %default]"),
    
    make_option(c("-C", "--column_compare"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in compared file [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = " ", action = "store",
                help = "The field separator character.Note: if the character has '\', then add a quote, write as -s '\\t' [default '%default']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]"),
    
    make_option(c("-m", "--comment_char"), type = "character", default = "", action = "store",
                help = "The \"comment.char\" argument in \"read.table\" function in R. Used to read the file in R [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_rand_index_1vs1.R -r no1/ENCODE_27_Markers.state -c no2/ENCODE_27_Markers.state -R 5 -C 5 -s ' '"
  description_message <- "This Script is to calculate the ARI value between one ideas state output and another ideas state output."
  
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
  reference <- compare <- "ENCODE_cells.state"
  header <- T
  sep <- " "
  comment_char <- ""
  column_ref <- 5
  column_compare <- 6
}

# read in data
if (T) {
  reference <- data.table::fread(reference, header = header, sep = sep, skip = comment_char, data.table=F)[,column_ref]
  compare <- data.table::fread(compare, header = header, sep = sep, skip = comment_char, data.table=F)[,column_compare]
}

# rand index calculation
if (T) {
  # rand index
  ri <- flexclust::randIndex(table(reference,compare),correct = F)
  # adjusted rand index
  ari <- flexclust::randIndex(table(reference,compare),correct = T)
}

# print results
if (T) {
  message <- paste0("RI value:",ri,";","ARI value:",ari,"\n")
  cat(message)
}


