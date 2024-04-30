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
    make_option(c("-a", "--userSet"), type = "character", default = "userSet.txt", action = "store",
                help = "The input interested vectors, e.g., DEGs [default %default]"),
    
    make_option(c("-b", "--target_term"), type = "character", default = "target_term.txt", action = "store",
                help = "**One** input interested terms, e.g., GO or KEGG [default %default]"),
    
    make_option(c("-c", "--anno_label"), type = "character", default = "anno_label", action = "store",
                help = "The annotation label for target term [default %default]"),
    
    make_option(c("-d", "--total_number"), type = "integer", default = 1000, action = "store",
                help = "The number of all possible vectors, which is more than the number of userset [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "output to screen", action = "store",
                help = "The output file. Not necessary. If not set this, the result will output to screen [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript statistics_hypergeometric_test.R -a peak.txt -b term.txt -c cell_cycle -d 2000 -o enrichment_analysis.txt"
  description_message <- "This Script is to perform hypergeometric test analysis."
  
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
  userSet <- data.table::fread(userSet, header = header, data.table = F)[,1]
  target_term <- data.table::fread(target_term, header = header, data.table = F)[,1]
  
  out <- ifelse(output == "output to screen", F, T)
}

# enrichment analysis function
if (T) {
  enrichment <- function(userSet,
                         total_number,
                         target_term,
                         anno_label) {
    # Description
    if (T) {
      # n: All DEGs
      # N: All genes
      # k: DEGs in TermA
      # M: All genes in TermA
      
      # enrichment P: phyper(k-1,M,N-M,n,lower.tail = F)
      # enrichment fold change: (k/n)/(N/M)=kN/nM
    }
    
    # n: All DEGs
    n <- length(userSet)
    
    # N: All genes
    N <- total_number
    
    # M: All genes in TermA
    M <- length(target_term)
    
    # k: DEGs in TermA
    k <- sum(userSet %in% target_term)
    
    # enrichment P: phyper(k-1,M,N-M,n,lower.tail = F)
    p <- phyper(k-1, M, N-M, n, lower.tail = F)
    
    # enrichment fold change: (k/n)/(N/M)=kN/nM
    term_in_DEG <- k / n
    term_in_BG <- M / N
    fc <- term_in_DEG / term_in_BG
    
    # output
    enrich <- data.frame(Name = anno_label,
                         All_genes_N = N,
                         All_genes_in_term_M = M,
                         All_DEGs_n = n,
                         DEGs_in_Term_k = k,
                         P_hyper = p,
                         term_in_DEG = term_in_DEG, 
                         term_in_BG = term_in_BG,
                         Log2FC = log2(fc))
    return(enrich)
  }
}

# enrichment analysis
if (T) {
  enrich <- enrichment(userSet,
                       total_number,
                       target_term,
                       anno_label)
  colnames(enrich)[1] <- "#Name"
}

if (out) {
  write.table(enrich, file = output, quote = F, sep = "\t", col.names = T, row.names = F)
}
if (! out) {
  print(enrich)
}
