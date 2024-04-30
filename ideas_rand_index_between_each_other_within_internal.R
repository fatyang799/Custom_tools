

# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(stringr)
  library(parallel)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "A file recording input files list [default %default]"),
    
    make_option(c("-n", "--file_name"), type = "character", default = "file.name", action = "store",
                help = "A file recording the name for input files list, which make results more human readable [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "Whether the file has a header colnames. If set this, this means \"header=F\" [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character, write the separator character within a quote [default \"\\t\"]"),
    
    make_option(c("-c", "--column"), type = "double", default = 5, action = "store",
                help = "The target value in which column in the file [default %default]"),
    
    make_option(c("-o", "--output_ARI"), type = "character", default = "paired_ARI.tab", action = "store",
                help = "Output paired ARI results [default %default]"),
    
    make_option(c("-O", "--output_RI"), type = "character", default = "paired_RI.tab", action = "store",
                help = "Output paired ARI results [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_ari_paired_list_internal.R -i file.txt -n file.name -s \" \" -c 5 -o paired_ARI.tab -O paired_RI.tab"
  
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
  file_name <- "file.name"
  header <- T
  sep <- " "
  column <- 5
  output_ARI <- "paired_ARI.tab"
  output_RI <- "paired_RI.tab"
}

# all combination
if (T) {
  # read the data
  if (T) {
    files <- read.table(input,header=F)[,1]
    name <- read.table(file_name,header=F)[,1]
    if (length(files) != length(name)) {
      stop("The length of input and file_name is not identical, please check the files.")
    }
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

# paired rand index analysis
if (T) {
  rds <- paste0(dirname(output_ARI),"/paired_ARI_RI.rds")
  
  if (file.exists(rds)) {
    results = readRDS(rds)
  }
  
  if (!file.exists(rds)) {
    # set multicore environment
    cl <- makeCluster(20, outfile=paste0(dirname(rds),"/paired_ARI_RI_multi_c.log"), type="FORK")
    # cl <- makeCluster(2, outfile=paste0(dirname(rds),"/paired_ARI_RI_multi_c.log"))
    
    # export the environment variables
    clusterExport(cl, ls(), envir = environment())
    
    # calculation
    results <- parLapply(cl, 1:(n_files-1), function(x) {
      # get file name
      fname1 <- files[x]
      print(x)
      
      f1 <- data.table::fread(fname1, header = header, sep = sep, skip = "", data.table=F)[,column]
      
      f2n <- mat[,x]
      f2n <- f2n[!is.na(f2n)]
      
      res2 <- lapply(f2n, function(fname2){
        fname2 <- files[fname2]
        f2 <- data.table::fread(fname2, header = header, sep = sep, skip = "", data.table=F)[,column]
        
        tab <- table(f1, f2)
        ri <- flexclust::randIndex(tab,correct = F)
        ari <- flexclust::randIndex(tab,correct = T)
        
        res1 <- c(ri,ari)
        res1
      })
      res2
    })
    
    # stop the multicore environment and save the result 
    stopCluster(cl)
    saveRDS(results, file=rds)
  }
}

# export the results to matrix
if (T) {
  ri_mat <- data.frame()
  ari_mat <- data.frame()
  
  for (i in 1:n_files) {
    if (i == n_files) {
      ri_mat[i,i] <- 1
      ari_mat[i,i] <- 1
    }
    if (i < n_files) {
      cor <- results[[i]]
      
      loc <- as.numeric(names(cor))
      ri_ari <- do.call(c, cor)
      
      ri_mat[loc,i] <- ri_ari[seq(1, length(ri_ari), 2)]
      ri_mat[i,loc] <- ri_ari[seq(1, length(ri_ari), 2)]
      ri_mat[i,i] <- 1
      
      ari_mat[loc,i] <- ri_ari[seq(2, length(ri_ari), 2)]
      ari_mat[i,loc] <- ri_ari[seq(2, length(ri_ari), 2)]
      ari_mat[i,i] <- 1  
    }
  }
}

# change the names of matrix
if (T) {
  rownames(ri_mat) <- colnames(ri_mat) <- name
  rownames(ari_mat) <- colnames(ari_mat) <- name
}

# output
if (T) {
  write.table(ri_mat, output_RI, row.names = T, col.names = T, sep = "\t",quote = F)
  write.table(ari_mat, output_ARI, row.names = T, col.names = T, sep = "\t",quote = F)
}


