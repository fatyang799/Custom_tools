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
    make_option(c("-e", "--selected_exp"), type = "character", default = "selected_Exp_manually.txt", action = "store",
                help = "Selected experimental samples by manually checking [default %default]"),
    
    make_option(c("-m", "--metadata"), type = "character", default = "2.Experiment_ID_info.csv", action = "store",
                help = "The experimental metadata, which derive from the spider results and record the CT information [default %default]"),
    
    make_option(c("-c", "--bestCT"), type = "character", default = "automatic_selected_CT_based_on_depth_enrich.txt", action = "store",
                help = "The best CT in each input ChIPseq experimente, which record the selected Exp sample based on sequence depth and enrichment level [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "Exp_CT_list.txt", action = "store",
                help = "Output the selected EXP and corresponding CT id [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript selection_Exp_CT_list.R -e selected_Exp_manually.txt -m 2.Experiment_ID_info.csv -c automatic_selected_CT_based_on_depth_enrich.txt -o Exp_CT_list.txt"
  description_message <- "This Script is to select best CT samples based on selected experimental samples."
  
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
  selected_exp <- "H9/EXP/selected_Exp_manually.txt"
  metadata <- "H9/EXP/2.Experiment_ID_info.csv"
  bestCT <- "H9/EXP/automatic_selected_CT_based_on_depth_enrich.txt"
  output <- "H9/EXP/Exp_CT_list.txt"
}

# get selected EXP
if (T) {
  # read in selected EXP data
  if (T) {
    selected_exp <- read.table(selected_exp, header = F, sep = ",")
    selected_exp <- selected_exp[,1]
  }
  
  # read in detailed metadata
  if (T) {
    metadata <- read.table(metadata,header = T,sep = ",")
    metadata$File_name <- ifelse(metadata$Run_mode=="single-ended",
                                 gsub("R..fq.gz","SE",metadata$File_name),
                                 gsub("R..fq.gz","PE",metadata$File_name))
    
    metadata <- metadata[metadata$File_name %in% selected_exp,]
    metadata <- metadata[!duplicated(metadata$File_name),]
  }
  
  # get required data
  if (T) {
    colnames(metadata)
    metadata <- metadata[,c("File_name", "Control")]
  }
}

# CT selection
if (T) {
  # get all best CT
  if (T) {
    bestCT <- read.table(bestCT, header = T, sep = "\t")
  }
  
  # all situation
  if (T) {
    ct <- tapply(metadata$Control, metadata$File_name, function(x){
      strsplit(x,";")[[1]]
    })
  }
  
  # selection
  if (T) {
    ct <- lapply(ct, function(x){
      value <- bestCT[match(x,bestCT$ExpID), "selected_value"]
      selected <- bestCT[bestCT$selected_value==max(value),1]
      selected
    })
  }
  
  # format the result
  if (T) {
    result <- do.call(c,ct)
    result <- data.frame(EXP = names(result),
                         CT = result)
  }
}

# output
if (T) {
  write.table(result, file = output, row.names = F, col.names = F,sep = "\t", quote = F)
}

