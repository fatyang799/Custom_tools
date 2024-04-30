# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(reshape2)
  library(ggplot2)
  library(ggpubr)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file, which should be a matrix format. No characters exist in the file, except for header of file only when there is a header [default %default]"),
    
    make_option(c("-x", "--x_name"), type = "character", default = NULL, action = "store",
                help = "The file record the x label in the figure. The order of the x_name should be same as the column of input [default %default]"),
    
    make_option(c("-u", "--upper"), type = "double", default = NULL, action = "store",
                help = "The upper limit of value for each sample (<=$upper). Filtering is done individually for each sample [default %default]"),
    
    make_option(c("-l", "--lower"), type = "double", default = NULL, action = "store",
                help = "The lower limit of value for each sample (>=$upper). Filtering is done individually for each sample [default %default]"),
    
    make_option(c("-o", "--output_pic"), type = "character", default = NULL, action = "store",
                help = "The output boxplot file name [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"fread\" function in R. Used to read the file in R. [default %default]"),
    
    make_option(c("-w", "--width"), type = "double", default = 8, action = "store",
                help = "The \"width\" argument in \"ggsave\" function in R. Used to save the figure in R [default %default]"),
    
    make_option(c("-t", "--height"), type = "double", default = 6, action = "store",
                help = "The \"height\" argument in \"ggsave\" function in R. Used to save the figure in R [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_boxplot.R -i ARI_statistics.txt -x marker.txt -o H1_ari.png -O H1_ari.tab"
  description_message <- "This Script is to plot boxplot according to a file record a matrix."
  
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
  input <- "123.txt"
  x_name <- "name.txt"
  upper <- 4
  lower <- 2
  header <- F
  sep <- "\t"
  output_pic <- "test.png"
  width <- 8
  height <- 6
}

# read data
if (T) {
  dat <- data.table::fread(input, header = header, sep = sep, data.table = F)
  name <- data.table::fread(x_name, header = F, data.table = F)[,1]
  colnames(dat) <- name
}

# wide to long and sorting
if (T) {
  ggdat <- melt(data = dat, id.vars = NULL)
  ggdat$value <- as.numeric(ggdat$value)
}

# filter
if (T) {
  if (exists("upper")) {
    ggdat <- ggdat[ggdat$value <= upper, ]
  }
  
  if (exists("lower")) {
    ggdat <- ggdat[ggdat$value >= lower, ]
  }
}

# sorting
if (T) {
  order <- sort(tapply(ggdat$value, ggdat$variable, mean), decreasing = T)
  ggdat$variable <- factor(ggdat$variable,levels = names(order))  
}

# ggplot
if (T) {
  ggplot(data = ggdat) +
    geom_boxplot(aes(x=variable, y=value, color=variable)) +
    xlab(NULL) +
    ylab(NULL) +
    theme(axis.text.x = element_text(size = rel(1.2), angle = 90, hjust = 1, vjust = 0.5),
          axis.text.y = element_text(size = rel(1.2)),
          legend.position = "none")
  
  # output picture file
  ggsave(filename = output_pic, width = width, height = height)
}


