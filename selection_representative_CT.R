# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(ggplot2)
  library(ggrepel)
  library(stringr)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-s", "--selected_value"), type = "character", default = "merge_depth_enrich_selected_Value.txt", action = "store",
                help = "Input table file, which record the depth, enrichment and selected_value [default %default]"),
    
    make_option(c("-m", "--metadata"), type = "character", default = "3.Control_ID_info.csv", action = "store",
                help = "The CT metadata, which derive from the spider results [default %default]"),
    
    make_option(c("-t", "--output_tab"), type = "character", default = "automatic_selected_CT_based_on_depth_enrich.txt", action = "store",
                help = "Output the table, which record the selected CT sample based on sequence depth and enrichment level [default %default]"),
    
    make_option(c("-p", "--output_pic"), type = "character", default = "automatic_selected_CT_based_on_depth_enrich.png", action = "store",
                help = "Output the figure, which plot all CT sample based on sequence depth and enrichment level [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript selection_representative_CT.R -s merge_depth_enrich_selected_Value.txt -m 3.Control_ID_info.csv -t automatic_selected_CT_based_on_depth_enrich.txt -p automatic_selected_CT_based_on_depth_enrich.png"
  description_message <- "This Script is to select best CT samples based on sequence depth and enrichment level."
  
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
  selected_value <- "H9/EXP/merge_depth_enrich_selected_Value.txt"
  metadata <- "H9/EXP/3.Control_ID_info.csv"
  output_tab <- "H9/EXP/automatic_selected_CT_based_on_depth_enrich.txt"
  output_pic <- "H9/EXP/automatic_selected_CT_based_on_depth_enrich.png"
}

# load the data
if (T) {
  selected_value <- read.table(selected_value, header = T, sep = "\t")
  metadata <- read.table(metadata, header = T, sep = ",")
}

# format the data
if (T) {
  # metadata
  if (T) {
    colnames(metadata)
    metadata <- metadata[,c("File_name", "Experiment_ID", "Run_mode")]
    metadata$File_name <- ifelse(metadata$Run_mode=="single-ended",
                                 gsub("R..fq.gz","SE",metadata$File_name),
                                 gsub("R..fq.gz","PE",metadata$File_name))
    
    metadata <- metadata[!duplicated(metadata$File_name), ]
  }
  # selected_value
  if (T) {
    selected_value <- selected_value[grepl("input", selected_value$Sample), ]
  }
}

# merge the data
if (T) {
  dat <- merge(metadata, selected_value, by.x = "File_name", by.y = "Sample")
}

# selection EXP
if (T) {
  # get sample with max selected_value
  if (T) {
    best_CT <- tapply(dat$selected_value, dat$Experiment_ID, max)
    best_CT <- data.frame(ExpID=names(best_CT),
                           Selected_value=best_CT)  
  }
  
  # selected sample with max selected_value
  if (T) {
    for (i in 1:nrow(best_CT)) {
      id <- best_CT$ExpID[i]
      value <- best_CT$Selected_value[i]
      
      subdat <- dat[dat$Experiment_ID == id,]
      best_CT[id,"selected_file"] <- subdat[subdat$selected_value==value,1]
    }
  }
  
  # add additional information
  if (T) {
    best_CT <- merge(best_CT, selected_value, by.x = "selected_file", by.y = "Sample")
    best_CT <- best_CT[,-3]
  }
}

# plot
if (T) {
  for (i in unique(dat$Experiment_ID)) {
    n <- sum(dat$Experiment_ID==i)
    dat[dat$Experiment_ID==i, "File_n"] <- paste0("File",1:n)
  }
  
  ggplot(data = dat) +
    geom_point(aes(x = Synthetic.JS.Distance, y = total_passed, colour = File_n), size = 2) +
    geom_text_repel(aes(x = Synthetic.JS.Distance, y = total_passed, colour = File_n), label=dat$File_name, size=2) +
    xlab("Enrichment level") +
    ylab("Sequencing depth") +
    facet_wrap(~Experiment_ID, nrow = 3) +
    theme(axis.title.x = element_text(size = rel(1.2)),
          axis.title.y = element_text(size = rel(1.2)),
          strip.text = element_text(size = rel(1.2)),
          legend.position = "none")
  
  ggsave(filename = output_pic, height = 10, width = 10)
}

# output table
if (T) {
  write.table(best_CT, file = output_tab, quote = F, sep = "\t", row.names = F, col.names = T)
}

