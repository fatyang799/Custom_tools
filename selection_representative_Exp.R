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
    
    make_option(c("-g", "--group"), type = "character", default = "file.group", action = "store",
                help = "The group info for samples in selected_value file, e.g. H3K4me3, ATAC, RNA et al. **Note: the order must be same as selected_value file. The default order is not identical, so you need to modify it manually!** [default %default]"),
    
    make_option(c("-t", "--output_tab"), type = "character", default = "automatic_selected_EXP_based_on_depth_enrich.txt", action = "store",
                help = "Output the table, which record the selected Exp sample based on sequence depth and enrichment level [default %default]"),
    
    make_option(c("-p", "--output_pic"), type = "character", default = "automatic_selected_EXP_based_on_depth_enrich.png", action = "store",
                help = "Output the figure, which plot all Exp sample based on sequence depth and enrichment level [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript selection_representative_Exp.R -s merge_depth_enrich_selected_Value.txt -g file.group -t automatic_selected_EXP_based_on_depth_enrich.txt -p automatic_selected_EXP_based_on_depth_enrich.png"
  description_message <- "This Script is to select best EXP samples based on sequence depth and enrichment level."
  
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
  selected_value <- "merge_depth_enrich_selected_Value.txt"
  group <- "file.group"
  output_tab <- "automatic_selected_EXP_based_on_depth_enrich.txt"
  output_pic <- "automatic_selected_EXP_based_on_depth_enrich.png"
}

# load the data
if (T) {
  selected_value <- read.table(selected_value, header = T, sep = "\t")
  group <- read.table(group, header = F, sep = "\t")[,1]
}

# format the data
if (T) {
  # remove CT
  selected_value <- selected_value[!grepl("input", selected_value$Sample), ]
}

# merge the data
if (T) {
  selected_value$group <- group
  dat <- selected_value
}

# selection EXP
if (T) {
  # get sample with max selected_value
  if (T) {
    best_EXP <- tapply(dat$selected_value, dat$group, max)
    best_EXP <- data.frame(Target=names(best_EXP),
                           Selected_value=best_EXP)  
  }
  
  # selected sample with max selected_value
  if (T) {
    for (i in 1:nrow(best_EXP)) {
      target <- best_EXP$Target[i]
      value <- best_EXP$Selected_value[i]
      
      subdat <- dat[dat$group == target,]
      best_EXP[target,"selected_file"] <- subdat[subdat$selected_value==value,1]
    }  
  }
  
  # add additional information
  if (T) {
    best_EXP <- merge(best_EXP, selected_value, by.x = "selected_file", by.y = "Sample")
    best_EXP <- best_EXP[,-3]
  }
}

# plot
if (T) {
  for (i in unique(dat$group)) {
    n <- sum(dat$group==i)
    dat[dat$group==i, "File_n"] <- paste0("File",1:n)
  }
  
  ggplot(data = dat) +
    geom_point(aes(x = Synthetic.JS.Distance, y = total_passed, colour = File_n), size = 2) +
    geom_text_repel(aes(x = Synthetic.JS.Distance, y = total_passed, colour = File_n), label=dat$Sample, size=3) +
    xlab("Enrichment level") +
    ylab("Sequencing depth") +
    facet_wrap(~group, nrow = 4) +
    theme(axis.title.x = element_text(size = rel(1.2)),
          axis.title.y = element_text(size = rel(1.2)),
          strip.text = element_text(size = rel(1.2)),
          legend.position = "none")
  
  ggsave(filename = output_pic, height = 10, width = 10)
}

# output table
if (T) {
  write.table(best_EXP, file = output_tab, quote = F, sep = "\t", row.names = F, col.names = T)
}


