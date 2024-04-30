

# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(stringr)
  library(ggplot2)
  library(pheatmap)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file, it is a output \"xxx.para\" file of IDEAS"),
    
    make_option(c("-p", "--heatmap_file"), type = "character", default = NULL, action = "store",
                help = "the standard emission heatmap file name [default %default]"),
    
    make_option(c("-e", "--emission_file"), type = "character", default = NULL, action = "store",
                help = "The standard emission para table file name, which response to the emission heatmap [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = " ", action = "store",
                help = "The field separator character. Note: if the character has '\', then add a quote, write as -s '\\t' [default '%default']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]")
  )
}

# Analysis parameters
if (T) {
  option_object <- OptionParser(
    usage = "usage: %prog [options]\n\tRscript ideas_emission_heatmap.R -i ENCODE_27_Markers.para -n 27 -t para.tab\n",
    option_list = option_list,
    add_help_option = TRUE,
    description = "This Script is to analysis IDEAS ouptut para file and transfer to standard para file for downstream analysis."
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
}

# Test data
if (F) {
  input <- "ENCODE_cells.para"
  header <- T
  sep <- " "
  emission_file <- ""
  heatmap_file <- ""
}

# read data
if (T) {
  dat <- read.table(input, header = header, sep = sep, comment = "!", fill = T)
}

# get the number of marker
if (T) {
  l=nrow(dat)
  k=ncol(dat)
  n_marker <- (sqrt(9+8*(k-1))-3)/2
}

# calculate emission para
if (T) {
  m <- as.matrix(dat[,1+1:n_marker]/dat[,1])
  colnames(m) <- colnames(dat)[1+1:n_marker]
}

# get prop
if (T) {
  rownames(m) <- paste0(1:l-1, " (", round(dat[,1]/sum(dat[,1])*10000)/100, "%)")
}

# output emission
if (T) {
  emission <- data.frame(cbind(state=rownames(m), 
                               m))
  
  write.table(emission, file = emission_file, col.names = T, row.names = F, sep = "\t", quote = F)
}

# heatmap
if (T) {
  pheatmap(m, scale = "none",
           colorRampPalette(c("white","darkblue"))(100),
           cluster_cols = F, cluster_rows = T,
           clustering_method = "ward.D2",
           clustering_distance_rows = "euclidean",
           filename = heatmap_file, width = 15, height = 16,
           fontsize_col = 15, fontsize_row = 12,
           legend = F)
}


