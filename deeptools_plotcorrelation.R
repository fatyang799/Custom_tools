

# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(pheatmap)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "pearson_correlation.tab", action = "store",
                help = "The input file. It should be the output correlation matrix of plotCorrelation [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "pearson_correlation.png", action = "store",
                help = "the output file name [default %default]"),
    
    make_option(c("-w", "--width"), type = "integer", default = 14, action = "store",
                help = "Manual option for determining the output file width in inches. [default %default]"),
    
    make_option(c("-H", "--height"), type = "integer", default = 12, action = "store",
                help = "Manual option for determining the output file height in inches. [default %default]"),
    
    make_option(c("-r", "--fontsize_row"), type = "integer", default = 20, action = "store",
                help = "Fontsize for rownames [default %default]"),
    
    make_option(c("-f", "--fontsize_number"), type = "integer", default = 13, action = "store",
                help = "Fontsize of the numbers displayed in cells [default %default]"),
    
    make_option(c("-u", "--upper"), type = "double", default = 1, action = "store",
                help = "The minium of range [default %default]"),
    
    make_option(c("-l", "--lower"), type = "double", default = -1, action = "store",
                help = "The maxium of range [default %default]"),
    
    make_option(c("-n", "--display_numbers"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether to display cor num in plot [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript deeptools_plotcorrelation.R -i pearson_correlation.tab -o pearson_correlation.png -n"
  description_message <- "This Script is to plot correlation heatmap based on deeptools plotCorrelation."
  
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
  dat <- read.table(input,header = T,sep = "\t",row.names=1)
}

# correlation heatmap
if(T){
  pheatmap(as.matrix(dat),scale="none",
           show_colnames=F,show_rownames=T,
           breaks=seq(lower,upper,length.out=100),
           cluster_cols=T,cluster_rows=T,
           border_color="black",colorRampPalette(c("blue","white","red"))(100),
           fontsize_row=fontsize_row,fontsize_number=fontsize_number,
           filename=output,width=width,height=height,
           display_numbers=display_numbers)
}
