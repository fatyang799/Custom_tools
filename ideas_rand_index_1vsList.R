

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
    make_option(c("-r", "--reference"), type = "character", default = NULL, action = "store",
                help = "The reference of ideas state file [default %default]"),
    
    make_option(c("-c", "--compare_list"), type = "character", default = NULL, action = "store",
                help = "A file list, which include ideas state files to be compared with ref [default %default]"),
    
    make_option(c("-R", "--column_ref"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in reference file [default %default]"),
    
    make_option(c("-C", "--column_compare"), type = "integer", default = 5, action = "store",
                help = "Which column of file record the value in compared file [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "ri_ari_ref_targets.xls", action = "store",
                help = "Output results file [default %default]"),
    
    make_option(c("-d", "--rds"), type = "character", default = "ri_ari_ref_targets.rds", action = "store",
                help = "RDS data to save the output of parallelly running. Which is useful if you need to re-run the processs [default %default]"),
    
    make_option(c("-l", "--log"), type = "character", default = "rand_multi_c.log", action = "store",
                help = "The log file used to record parallelly running info [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = " ", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '%default']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_rand_index_1vsList.R -r ENCODE_27_Markers.state -c file.txt -R 5 -C 5 -o ri_ari_ref_targets.xls -d ri_ari_ref_targets.rds -l rand_multi_c.log -s ' '"
  description_message <- "This Script is to calculate the ARI value between a ideas state output and a list of ideas state outputs."
  
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

# read in data
if (T) {
  compare_list <- read.table(compare_list,header = F)[,1]
}

# rand index parallel calculation
if (T) {
  if (!file.exists(rds)) {
    # read ref data
    ref <- data.table::fread(reference, header = header, sep = sep, data.table=F)[,column_ref]
    
    # multi-core environment
    if (T) {
      cl <- makeCluster(20, outfile=log, type="FORK")
      clusterExport(cl, ls(), envir = environment())  
    }
    
    # read compare_list data and calculate rand index
    if (T) {
      rand_value <- parLapply(cl,1:length(compare_list), function(x) {
        print(x)
        
        # read in compared data
        if (T) {
          compare <- compare_list[x]
          compare <- data.table::fread(compare, header = header, sep = sep, data.table=F)[,column_compare]
        }
        
        # calculate (adjusted) rand index
        if (T) {
          ri <- flexclust::randIndex(table(ref,compare),correct = F)
          ari <- flexclust::randIndex(table(ref,compare),correct = T)
        }
        
        # return results
        if (T) {
          index <- c(ri,ari)
          return(index)
        }
      })
    }
    
    # stop multicore environment
    stopCluster(cl)
    
    # save results
    saveRDS(rand_value, file=rds)
  }
  if (file.exists(rds)) {
    rand_value = readRDS(rds)
  }
}

# manage result data.frame
if (T) {
  results <- data.frame(reference=reference,
                        compare_list=compare_list)
  
  for (i in 1:length(compare_list)) {
    compare=compare_list[i]
    
    # assign the ri and ari
    ri <- rand_value[[i]][1]
    ari <- rand_value[[i]][2]
    
    # merge the matrix
    results[results$compare_list==compare,"ri"]=ri
    results[results$compare_list==compare,"ari"]=ari
  }
}

# output results
if (T) {
  write.table(results, file = output, row.names = F, col.names = T, sep = "\t", quote = F)
}


