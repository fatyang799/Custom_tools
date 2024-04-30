

# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(parallel)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-a", "--file_list1"), type = "character", default = "file1.txt", action = "store",
                help = "File list 1, which record a list of IDEAS output state file [default %default]"),
    
    make_option(c("-b", "--file_list2"), type = "character", default = "file2.txt", action = "store",
                help = "File list 2, which record a list of IDEAS output state file [default %default]"),
    
    make_option(c("-C", "--file_name1"), type = "character", default = "file1.name", action = "store",
                help = "Provide a file recording the label for file list1 [default %default]"),
    
    make_option(c("-D", "--file_name2"), type = "character", default = "file2.name", action = "store",
                help = "Provide a file recording the label for file list2 [default %default]"),
    
    make_option(c("-A", "--file_column1"), type = "double", default = 5, action = "store",
                help = "The column of state number recorded in files within file_list1 [default %default]"),
    
    make_option(c("-B", "--file_column2"), type = "double", default = 5, action = "store",
                help = "The column of state number recorded in files within file_list2 [default %default]"),
    
    make_option(c("-o", "--output_ri"), type = "character", default = "file1_file2_RI_multi_vs_multi.xls", action = "store",
                help = "The output file name for ri matrix [default %default]"),
    
    make_option(c("-O", "--output_ari"), type = "character", default = "file1_file2_ARI_multi_vs_multi.xls", action = "store",
                help = "The output file name for ari matrix [default %default]"),
    
    make_option(c("-d", "--rds"), type = "character", default = "ri_ari_ref_targets.rds", action = "store",
                help = "RDS data to save the output of parallelly running. Which is useful if you need to re-run the processs [default %default]"),
    
    make_option(c("-l", "--log"), type = "character", default = "rand_multi_c.log", action = "store",
                help = "The log file used to record parallelly running info [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = " ", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '%default']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]"),
    
    make_option(c("-m", "--comment_char"), type = "character", default = "", action = "store",
                help = "The \"comment.char\" argument in \"read.table\" function in R. Used to read the file in R [default \"%default\"]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_ARI_between_two_list_files.R -a file1.txt -b file2.txt -A 5 -B 5 -C file1.name -D file2.name -o 27_26_ARI.xls -O 27_26_RI.xls -d ri_ari_ref_targets.rds -l ri_ari_ref_targets.log"
  description_message <- "This Script is to calculate the ARI value between 2 list of files."
  
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
  list1 <- read.table(file_list1,header = F)[,1]
  list2 <- read.table(file_list2,header = F)[,1]
}

# parallel calculate
if (T) {
  if (!file.exists(rds)) {
    cl <- makeCluster(20, outfile=log, type="FORK")
    clusterExport(cl,ls(),envir = environment())
    
    results <- parLapply(cl, list1, function(fname1){
      print(fname1)
      f1 <- data.table::fread(fname1, header = header, sep = sep, skip = comment_char, data.table=F)[,file_column1]
      
      result <- lapply(list2, function(fname2){
        print(fname2)
        f2 <- data.table::fread(fname2, header = header, sep = sep, skip = comment_char, data.table=F)[,file_column2]
        ri <- flexclust::randIndex(table(f1,f2),correct = F)
        ari <- flexclust::randIndex(table(f1,f2),correct = T)
        res<- c(ri,ari)
        return(res)
      })
      return(result)
    })
    stopCluster(cl)
    saveRDS(results,file=rds)
  }
  if (file.exists(rds)) {
    results = readRDS(rds)
  }
}

# assign the results to the matrix
if (T) {
  ri_mat <- data.frame()
  ari_mat <- data.frame()
  
  for (f1 in 1:length(list1)) {
    for (f2 in 1:length(list2)) {
      fname1 <- list1[f1]
      fname2 <- list2[f2]
      
      # 分配相关系数
      ri=results[[f1]][[f2]][1]
      ari=results[[f1]][[f2]][2]
      
      # 分配相关系数给文件对应的矩阵位置
      ri_mat[fname1,fname2]=ri
      ari_mat[fname1,fname2]=ari
    }
  }
}

# modify the row and col names
if (T) {
  # name1
  if (T) {
    name1 <- read.table(file_name1,header = F)[,1]
    rownames(ri_mat) <- name1
    rownames(ari_mat) <- name1
  }
  
  # name2
  if (T) {
    name2 <- read.table(file_name2,header = F)[,1]
    colnames(ri_mat) <- name2
    colnames(ari_mat) <- name2
  }
}

# output 
if (T) {
  ri_mat <- cbind(data.frame(file=rownames(ri_mat)),ri_mat)
  ari_mat <- cbind(data.frame(file=rownames(ari_mat)),ari_mat)
  
  write.table(ri_mat,file = output_ri,row.names = F,col.names = T,sep = "\t",quote = F)
  write.table(ari_mat,file = output_ari,row.names = F,col.names = T,sep = "\t",quote = F)
}



