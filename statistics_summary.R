# Load environment
if (T) {
  rm(list = ls())
  options(warn =-1)
  options(stringAsFactors = F)
  library(stringr)
  library(optparse)
  library(parallel)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store", 
                help = "The input file [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = FALSE, action = "store_true", 
                help = "Whether the file has header [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store", 
                help = "The field separator character [default \"%default\"]"),
    
    make_option(c("-c", "--column"), type = "integer", default = 1, action = "store", 
                help = "Which column of file record the value [default %default]"),
    
    make_option(c("-r", "--rounding"), type = "logical", default = FALSE, action = "store_true", 
                help = "Whether rounding the numbers [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript statistics_summary.R -i H3K27me3.bedgraph -c 4"
  description_message <- "This Script is to calculate statistics value for a file"
  
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
}

# Read input file
if (T) {
  dat <- data.table::fread(input, header = header, sep = sep, data.table = F)[,column]
  dat <- as.numeric(dat)
}

# Calculation
if (T) {
  min <- min(dat)
  max <- max(dat)
  
  mean <- mean(dat)
  median <- median(dat)
  
  sd <- sd(dat)
  variance <- var(dat)
  
  q10 <- quantile(dat, probs=0.10)
  q25 <- quantile(dat, probs=0.25)
  q50 <- quantile(dat, probs=0.50)
  q75 <- quantile(dat, probs=0.75)
  q90 <- quantile(dat, probs=0.90)
  
  sum <- sum(dat)
  
  results <- data.frame(file=input,
                        min=min,
                        max=max,
                        mean=mean,
                        median=median,
                        sd=sd,
                        variance=variance,
                        q10=q10,
                        q25=q25,
                        q50=q50,
                        q75=q75,
                        q90=q90,
                        sum=sum)
  rownames(results) <- NULL
}

# Output
if (T) {
  if (rounding) {
    results[,2:ncol(results)] <- round(results[,2:ncol(results)])
  }
  print(results, width=800)
}


