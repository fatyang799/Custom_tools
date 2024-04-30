# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
}

# get arguments
if (T) {
  args <- commandArgs(trailingOnly = T)
  input_mat <- args[1]
  input_lab <- args[2]
  output <- args[3]
}

# read raw data
if (T) {
  dat <- data.table::fread(input_mat, sep = "\t", header = F, data.table = F, nThread=20)
  target_label <- read.table(input_lab, header = F)[, 1]
  target_label <- paste0("'", target_label, "'")
}

# select label
if (T) {
  # torf choose
  if (T) {
    all_labels <- sapply(dat[1, ], c)
    all_labels <- as.vector(all_labels)
    
    target_label <- c(target_label, all_labels[1:3])
    torf <- all_labels %in% target_label  
  }
  
  # select mat 
  if (T) {
    dat <- dat[, torf]
  }
}

# output
write.table(dat, output, sep = "\t", row.names = F, col.names = F, quote = F)
