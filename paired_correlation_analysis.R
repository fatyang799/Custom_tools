

# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(stringr)
  library(parallel)
  library(ggplot2)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "A file recording input files list [default %default]"),
    
    make_option(c("-S", "--spearman"), type = "logical", default = FALSE, action = "store_true",
                help = "If set this, then calculating the spearman efficience [default %default]"),
    
    make_option(c("-n", "--file_name"), type = "character", default = "file.name", action = "store",
                help = "A file recording the name for input files list, which make results more human readable [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether the file has a header colnames [default %default]"),
    
    make_option(c("-z", "--skipZero"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether or not to skip the row where the paired 2 files both equal 0 [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "tab", action = "store",
                help = "The field separator character,either tab( ), comma(,), blank( ) or other [default \"%default\"]"),
    
    make_option(c("-c", "--column"), type = "numeric", default = 1, action = "store",
                help = "Which column of file record the value [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "paired_cor.tab", action = "store",
                help = "The output matrix file [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript paired_correlation_analysis.R -i file.txt -s \"\t\" -c 3 -o paired_cor.tab"
  description_message <- "This Script is to calculate paired correlation for files recorded in input file list."
  
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
  input <- "file.txt"
  name <- "file.name"
  spearman <- F
  header <- F
  skipZero <- T
  sep <- "\t"
  column <- 1
  output <- "paired_cor.tab"
}

# all combination
if (T) {
  # read the data
  if (T) {
    files <- read.table(input,header=F)[,1]
    name <- read.table(file_name,header=F)[,1]
  }
  
  # construct the comparison matrix
  if (T) {
    n_files <- length(files)  
    mat <- matrix(rep(1:n_files, n_files), nrow = n_files, ncol = n_files)
    rownames(mat) <- colnames(mat) <- 1:n_files
  }
  
  # remove redundent
  if (T) {
    for (i in 1:n_files) {
      mat[,i] <- ifelse(mat[,i]>i, mat[,i], NA)
    }
  }
}

# paired correlation ananlysis
if (T) {
  cor_type <- ifelse(spearman, "spearman", "pearson")
  rds <- paste0(dirname(output),"/paired_cor_",cor_type,".rds")
  
  if (file.exists(rds)) {
    results = readRDS(rds)
  }
  
  if (!file.exists(rds)) {
    # set multicore environment
    cl <- makeCluster(20, outfile=paste0(dirname(output),"/paired_cor_",cor_type,"_multi_c.log"), type="FORK")
    # cl <- makeCluster(2,outfile=paste0(dirname(output),"/paired_cor_",cor_type,"_multi_c.log"))
    
    # export the environment variables
    clusterExport(cl, ls(), envir = environment())
    
    # calculation
    results <- parLapply(cl, 1:n_files, function(x) {
      # get file name
      fname1 <- files[x]
      print(x)
      
      f1 <- read.table(fname1,header = header)[,column]
      
      f2n <- mat[,x]
      f2n <- f2n[!is.na(f2n)]
      
      cor <- lapply(f2n, function(fname2){
        fname2 <- files[fname2]
        f2 <- read.table(fname2,header = header)[,column]
        
        # skip 0s
        f <- cbind(f1,f2)
        if (skipZero) {
          f <- f[apply(f, 1, sum)>0,]
        }
        
        # calculating correlation efficience
        res <- ifelse(spearman, 
                      cor(f[,1],f[,2],method="spearman"), 
                      cor(f[,1],f[,2],method="pearson"))
        res
      })
    })
    
    # stop the multicore environment and save the result 
    stopCluster(cl)
    saveRDS(results,file=rds)
  }
}

# export the results to matrix
if (T) {
  for (i in 1:n_files) {
    cor <- results[[i]]
    
    loc <- as.numeric(names(cor))
    mat[loc,i] <- do.call(c, cor)
    mat[i,loc] <- do.call(c, cor)
    mat[i,i] <- 1
  }
}

# change the names of matrix
if (T) {
  rownames(mat) <- colnames(mat) <- name
}

# output
if (T) {
  write.table(mat, output, row.names = T, col.names = T, sep = "\t",quote = F)
}



