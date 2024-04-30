# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  suppressPackageStartupMessages(library(infotheo))
  library(parallel)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-r", "--reference"), type = "character", default = NULL, action = "store",
                help = "the reference of ideas state file [default %default]"),
    
    make_option(c("-c", "--compare_list"), type = "character", default = NULL, action = "store",
                help = "a file list, which include ideas state files to be compared with ref [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "tab", action = "store",
                help = "The field separator character,either tab, comma(,), blank( ) or other [default \"%default\"]"),
    
    make_option(c("-v", "--value1"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in reference file [default %default]"),
    
    make_option(c("-V", "--value2"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in compared file [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "dirnames(compare_list)/mi_nmi_ref_target.xls", action = "store",
                help = "Output results file [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_nmi.R -r ENCODE_27_Markers.state -c file.txt -s blank"
  description_message <- "This Script is to calculate the NMI value between a ideas state output and a list of ideas state outputs."
  
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

# Manage the parameters
if (T) {
  output <- ifelse(output=="dirname(compare_list)/mi_nmi_ref_target.xls",paste0(dirname(compare_list),"/ri_ari_ref_target.xls"),output)
}

# read in data 
if (T) {
  target <- read.table(compare_list,header = F)[,1]
}

# NMI parallel calculation
if (T) {
  rds <- paste0(dirname(compare_list),"/mi_nmi_ref_target.rds")
  if (!file.exists(rds)) {
    # read ref data
    ref <- read.table(reference,header = T,sep = " ",comment.char = "")[,value1]
    # multicore environment
    cl <- makeCluster(20,outfile=paste0(dirname(compare_list),"/nmi_multi_c.log"),type="FORK")
    clusterExport(cl,c("target","ref","value2"),envir = environment())
    # read target data and calculate rand index
    nmi_value <- parLapply(cl,1:length(target), function(x) {
      print(x)
      
      # read in compared data
      if (T) {
        compare <- target[x]
        compare <- read.table(compare,header = T,sep = " ",comment.char = "")[,value2]
      }
      
      # calculate (adjusted) rand index
      if (T) {
        mi <- mutinformation(ref,compare)
        nmi <- mi/sqrt(entropy(ref)*entropy(compare))
      }
      
      # return results
      if (T) {
        index <- c(mi,nmi)
        return(index)
      }
    })
    # stop multicore environment
    stopCluster(cl)
    saveRDS(nmi_value,file=rds)
  }
  if (file.exists(rds)) {
    nmi_value = readRDS(rds)
  }
}

# manage result data.frame
if (T) {
  results <- data.frame(reference=reference,
                        target=target)
  
  for (i in 1:length(target)) {
    compare=target[i]
    # 分配相关系数
    mi <- nmi_value[[i]][1]
    nmi <- nmi_value[[i]][2]
    # 结果整合
    results[results$target==compare,"mi"]=mi
    results[results$target==compare,"nmi"]=nmi
  }
}

# output results
if (T) {
  write.table(results,file = output,row.names = F,col.names = T,sep = "\t",quote = F)
}
