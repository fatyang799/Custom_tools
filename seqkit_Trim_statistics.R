# load the environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
  library(reshape2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-r", "--raw"), type = "character", default = "fastq1.stat.txt", action = "store",
                help = "The statistics file of seqkit stat for raw fastq files [default %default]"),
    
    make_option(c("-t", "--trim"), type = "character", default = "fastq2.stat.txt", action = "store",
                help = "The statistics file of seqkit stat for trim fastq files [default %default]"),
    
    make_option(c("-o", "--output1"), type = "character", default = "raw_stat.png", action = "store",
                help = "The output figure file for seqkit stat result [default %default]"),
    
    make_option(c("-O", "--output2"), type = "character", default = "remain_p_stat.png", action = "store",
                help = "The output figure file for remain percentage result [default %default]"),
    
    make_option(c("-b", "--table"), type = "character", default = "remain_p_stat.txt", action = "store",
                help = "The output matrix file for remain percentage result [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript Trim_statistics.R -r 2.Raw_Qc/1.histone_chip/3.seqkit/fastq.stat.txt -t 4.Trim_Qc/1.histone_chip/3.seqkit/fastq.stat.txt -o raw_stat.png -O remain_p_stat.png"
  description_message <- "This Script is to plot dotplot for `seqkit stat`"
  
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
  raw <- "2.Raw_Qc/1.histone_chip/3.seqkit/fastq.stat.txt"
  trim <- "4.Trim_Qc/1.histone_chip/3.seqkit/fastq.stat.txt"
  output1 <- "raw_stat.png"
  output2 <- "remain_p_stat.png"
}

# get files
if (T) {
  raw <- read.table(raw, header = T, sep = "\t", fill = T, comment.char = "")
  trim <- read.table(trim, header = T, sep = "\t", fill = T, comment.char = "")
}

# keep order
if (T) {
  raw <- raw[order(raw$num_seqs, decreasing = T), ]
  trim <- trim[match(raw$file, trim$file), ]
}

# statistics
if (T) {
  # data format
  if (T) {
    raw$file <- trim$file <- gsub(".fq.gz", "", raw$file)
    
    stat <- trim[, 4:5]/raw[, 4:5]
    stat <- data.frame(File = raw$file,
                       stat)
    stat$Type <- "Remain_Percent"
    raw$Type <- "Raw"
    trim$Type <- "Trim"
  }
  
  # wide 2 long
  if (T) {
    # raw and trim
    if (T) {
      dat <- rbind(raw, trim)
      colnames(dat) <- c("file", "format", "type", 
                         "num_seqs", "sum_len", 
                         "min_len", "avg_len", "max_len", 
                         "Q1", "Q2", "Q3", 
                         "sum_gap", "N50", 
                         "Q20", "Q30", 
                         "GC", 
                         "Type")
      ggdat <- melt(dat, id.vars=c("file", "Type"), measure.vars = c("num_seqs", "sum_len", 
                                                                     "min_len", "avg_len", "max_len", 
                                                                     "Q1", "Q2", "Q3", 
                                                                     "Q20", "Q30"), 
                    value.name = "value", variable.name = "Dat_type")
    }
    
    write.table(stat, file = table, quote = F, sep = "\t", col.names = T, row.names = F)
    
    # percentage
    if (T) {
      head(stat)
      stat <- melt(stat, id.vars=c("File", "Type"), value.name = "value", variable.name = "Dat_type")
    }
    
    # order
    ggdat$file <- stat$File <- factor(raw$file, levels = raw$file)
  }
}

# ggplot
if (T) {
  # raw stat
  if (T) {
    head(ggdat)
    ggplot(data = ggdat) +
      geom_point(aes(x=file, y=value)) +
      scale_x_discrete(name = "", labels = NULL) +
      ylab("") +
      ggh4x::facet_grid2(Dat_type~Type, scales="free") +
      theme(axis.title = element_text(size = rel(1.1)),
            axis.text = element_text(size = rel(1.1)),
            strip.text = element_text(size = rel(1.2)))
    
    ggsave(output1, width = 15, height = 10)
  }
  
  # percent stat
  if (T) {
    head(stat)
    label <- stat[stat$Dat_type == "sum_len" & stat$value < 0.80, ]
    
    ggplot(data = stat) +
      geom_point(aes(x=File, y=value)) +
      scale_x_discrete(name = "", labels = NULL) +
      ylab("") +
      ggh4x::facet_grid2(Dat_type~Type, scales="free") +
#      ggrepel::geom_label_repel(data = label, aes(x=File, y=value, label=File), arrow = arrow(length = unit(0.2, "npc"))) +
      theme(axis.title = element_text(size = rel(1.1)),
            axis.text = element_text(size = rel(1.1)),
            strip.text = element_text(size = rel(1.2)))
    
    ggsave(output2, width = 15, height = 10)
  }
}

