# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  suppressPackageStartupMessages(library(IRanges))
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-s", "--seed"), type = "integer", default = 2023, action = "store",
                help = "Random number seed [default %default]"),
    
    make_option(c("-n", "--number"), type = "integer", default = 10, action = "store",
                help = "Total number for random value [default %default]"),
    
    make_option(c("-b", "--begin"), type = "integer", default = 0, action = "store",
                help = "The begin region, 0-based [default %default]"),
    
    make_option(c("-e", "--end"), type = "integer", default = 100, action = "store",
                help = "The end region, 0-based [default %default]"),
    
    make_option(c("-x", "--exclude"), type = "character", default = "blackList.bed", action = "store",
                help = "The file record excluded region, where there are 2 column value. 1st for start, 2nd for end [default %default]"),
    
    make_option(c("-w", "--window_size"), type = "integer", default = 200, action = "store",
                help = "The windows siez [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = NULL, action = "store",
                help = "The output file")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript statistics_random_windows.R -i meta.txt -s 2023 -b 0 -e 1000 -x blackList.bed -w 200 -o random.txt"
  description_message <- "This Script is to random produce given window size fasta."
  
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
  seed <- 2023
  number <- 10
  begin <- 0
  end <- 1000
  exclude <- "test.bed"
  window_size <- 200
  output <- "output.txt"
}

set.seed(seed)

if(number > end*0.90) {
  stop("The number is more than 90%")
}

# get black region
if (T) {
  # 0-based for exclude
  black <- read.table(exclude, header = F, sep = "\t")
  colnames(black) <- c("start", "end")
  
  # 1-based
  black <- IRanges(start = black$start+1, end = black$end)
}

# get region object
if (T) {
  # get target number random value for start site
  rand <- sample(begin:(end-window_size), number)
  
  target <- IRanges(start = rand+1, width = window_size)
  
  # remove balck region
  if (T) {
    target <- target[!target %over% black]
    
    while (length(target) < number) {
      rand_bkp <- sample(begin:(end-window_size), number-length(target))
      rand_bkp <- rand_bkp[! rand_bkp %in% rand]
      
      target_bkp <- IRanges(start = rand_bkp+1, width = window_size)
      target_bkp <- target_bkp[!target_bkp %over% black]
      
      target <- c(target, target_bkp)
    }
  }
}

# output 0-based
data <- data.frame(start = start(target)-1,
                   end = end(target),
                   width = width(target))

write.table(data, file = output, quote = F, sep = "\t", col.names = T, row.names = F)
