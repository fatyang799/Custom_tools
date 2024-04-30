# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-r", "--ref"), type = "character", default = NULL, action = "store",
                help = "The emission para file of chromatin state with **most** chromatin state (tab as separator) [default %default]"),
    
    make_option(c("-c", "--compare_list"), type = "character", default = NULL, action = "store",
                help = "The compared emission para file list, which record a list of para files (tab as separator) [default %default]"),
    
    make_option(c("-s", "--state_col"), type = "integer", default = 1, action = "store",
                help = "Which column represent the name of state [default %default]"),
    
    make_option(c("-e", "--regular_express"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether use regular expression to extract names for list of para files. If set -e, then NOT set -m [default %default]"),
    
    make_option(c("-p", "--pattern"), type = "character", default = NULL, action = "store",
                help = "If -e exist, then this is the pattern for regular expression to extract name from compare_list [default %default]"),
    
    make_option(c("-m", "--manual"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether set the name for compare_list manually. If set -m, then NOT set -e [default %default]"),
    
    make_option(c("-n", "--name"), type = "character", default = NULL, action = "store",
                help = "If -m exist, then this is a file that record the name for for compare_list [default %default]"),
    
    make_option(c("-t", "--table"), type = "character", default = NULL, action = "store",
                help = "The results table file, which record the max correlation between state in ref and state in compare list [default %default]"),
    
    make_option(c("-o", "--output_pdf"), type = "character", default = NULL, action = "store",
                help = "The results heatmap plot file, which record the max correlation between state in ref and state in compare list [default %default]")
  )
}

# Analysis parameters
if (T) {
  option_object <- OptionParser(
    usage = "usage: %prog [options]\n\tRscript chromHMM_compareModels.R -r no1.para 27 -c file.txt -s 28 -e -p \"no[0-9]{1,2}\" -t compare.txt -o compare.pdf\n",
    option_list = option_list,
    add_help_option = TRUE,
    description = "This Script is a substitution for chromHMM compareModels."
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

# Manage the parameters
if (T) {
  plot_judge <- ifelse("output_pdf" %in% ls(),T,F)
  tab_judge <- ifelse("table" %in% ls(),T,F)
}

# read data
if (T) {
  # ref
  if (T) {
    ref <- read.table(ref,header = T,sep = "\t")
    # get colnames
    rownames(ref) <- ref[,state_col]
    ref <- ref[,-state_col]
    # get only histone column
    ref <- ref[,grepl(pattern = "H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?",colnames(ref))]
    # sort
    ref <- ref[,order(colnames(ref))]
  }
  
  # get file list
  if (T) {
    file_list <- read.table(compare_list,header = F)[,1]
    compare <- lapply(file_list, function(x){
      tar <- read.table(x,header = T,sep = "\t")
      rownames(tar) <- tar[,state_col]
      tar <- tar[,-state_col]
      tar <- tar[,grepl(pattern = "H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?",colnames(tar))]
      tar <- tar[,order(colnames(tar))]
    })
  }
  
  name <- file_list
  
  # if -m exist, then read the name to substitute name
  if (manual) {
    name <- read.table(name,header = F)[,1]
  }
  
  # if -e exist, then extract name to substitute name
  if (regular_express) {
    name <- str_extract_all(file_list,pattern,simplify = T)[,1]
  }
}

# calculation manually
if (T) {
  cor_mat <- sapply(compare, function(model){
    apply(ref, 1, function(state_ref){
      max(apply(model, 1, function(state_com){
        cor(state_ref,state_com)
      }))
    })
  })
  
  cor_mat <- as.data.frame(t(cor_mat))
  
  n_state <- sapply(compare, function(x)nrow(x))
  rownames(cor_mat) <- paste(name,"(",n_state,")",sep = "")
  colnames(cor_mat) <- rownames(ref)
  # sort
  cor_mat <- cor_mat[order(n_state),]
  
  cor_mat <- round(cor_mat,5)
  tab <- cor_mat
  # output table
  if (tab_judge) {
    tab$file <- rownames(tab)
    write.table(tab,file = table,quote = F,row.names = F,col.names = T,sep="\t")
  }
}

# heatmap plot
if (plot_judge) {
  min <- min(cor_mat)
  pheatmap::pheatmap(cor_mat,scale = "none",
                     breaks=seq(min,1,length.out=100),
                     colorRampPalette(c("white","red"))(100),
                     filename = output_pdf,width = 12,height = 4,
                     cluster_rows = F,cluster_cols = F,legend=T)
}
