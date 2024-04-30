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
    make_option(c("-d", "--depth"), type = "character", default = "multiqc_samtools_flagstat.txt", action = "store",
                help = "The sequencing depth summary file [default %default]"),
    
    make_option(c("-e", "--enrich"), type = "character", default = "deeptools_plot_fingerprint_with0_metrics.txt", action = "store",
                help = "The signal enrichment level summary file, which derive from deeptools plotFingerprint [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "merge_depth_enrich_selected_Value.txt", action = "store",
                help = "Output the table, which record the depth, enrichment and selected_Value [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript selection_merge_depth_enrich_selectedValue.R -d multiqc_samtools_flagstat.txt -e deeptools_plot_fingerprint_with0_metrics.txt -o merge_depth_enrich_selected_Value.txt"
  description_message <- "This Script is to calculate selected value based on sequence depth and enrichment level."

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
  depth <- "H9/EXP/multiqc_samtools_flagstat.txt"
  enrich <- "H9/EXP/deeptools_plot_fingerprint_with0_metrics.txt"
  output <- "H9/EXP/merge_depth_enrich_selected_Value.txt"
}

# get all depth info
if (T) {
  depth <- read.table(depth, header = T, sep = "\t")
  depth$Sample <- gsub(".stat", "", depth$Sample)
  colnames(depth)
  depth <- depth[,c("Sample", "total_passed")]
}

# get all enrichment info
if (T) {
  enrich <- read.table(enrich, header = T, sep = "\t")
  colnames(enrich)
  enrich <- enrich[,c("Sample", "Synthetic.JS.Distance")]
}

# merge depth and enrichment info and remove CT sample
if (T) {
  dat <- merge(depth, enrich, by = "Sample")
}

# get selected_value base on enrichment and depth
if (T) {
  dat$scaled_depth <- as.numeric(scale(dat$total_passed, center = F))
  dat$scaled_enrich <- as.numeric(scale(dat$Synthetic.JS.Distance, center = F))
  dat$selected_value <- ifelse(grepl("input", dat$Sample), dat$scaled_depth/dat$scaled_enrich, dat$scaled_depth*dat$scaled_enrich)
}

# output the table
if (T) {
  write.table(dat, file = output, quote = F, sep = "\t", row.names = F, col.names = T)
}

