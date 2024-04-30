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
    make_option(c("-i", "--input"), type = "character", default = "pvalue.txt", action = "store",
                help = "The input interested vectors, e.g., DEGs [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]"),
    
    make_option(c("-c", "--column"), type = "integer", default = 1, action = "store",
                help = "Which column of file record the P value [default %default]"),
    
    make_option(c("-a", "--append"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether append adjusted P value to the raw file. If set this, the `--output` will be ignored [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "FDR.txt", action = "store",
                help = "The output file. If set `-a/--append`, this argument will be ignored [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript statistics_fdr.R -i pvalue.txt -c 3 -H -s \"\\t\" -a"
  description_message <- "This Script is to Adjust P-values for Multiple Comparisons."
  
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
  
}

# read data
if (T) {
  dat <- data.table::fread(input, header = header, sep = sep, data.table = F)
}

# enrichment analysis function
if (T) {
  dat$FDR = p.adjust(dat[, column], method = "fdr")
}

# output
if (T) {
  output <- ifelse(append, input, output)
  
  mess <- ifelse(append, "The FDR value will append to raw file\n",
                 ifelse(output == "FDR.txt", 
                        "The FDR value will output to `FDR.txt`.\nYou can use `-o file` to set target output file.\n", 
                        paste0("The FDR value will output to `", output, "`")))
  
  write.table(dat, file = output, quote = F, sep = "\t", col.names = T, row.names = F)
}

