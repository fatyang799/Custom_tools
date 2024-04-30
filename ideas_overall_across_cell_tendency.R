# Load environment
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
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "The input file. It records files which record the ARI value between state after removing a marker and state with all markers [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_overall_across_cell_tendency.R"
  description_message <- "This Script is to plot overall tendency for IDEAS results"
  
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

# Test data
if (F) {
  input <- "file.txt"
}

# get all files
if (T) {
  files <- read.table(input, header = F)[,1]
}

# get all data
if (T) {
  dat <- lapply(files, function(x){
    cell <- str_extract(x,"1.H1|2.H9|3.IMR90")
    file <- read.table(x, header = T, sep = "\t")
    file$cell <- cell
    file
  })
  dat <- do.call(rbind,dat)
}

# overall_tendency_plot
if (T) {
  # prepare for data
  if (T) {
    ggdat <- dat[dat$order==1,]
    ggdat <- ggdat[order(ggdat$cell, ggdat$total, decreasing = c(F,T), method = "radix"),]
    
    ggdat$number <- factor(ggdat$number, paste0("no", seq(max(ggdat$total), min(ggdat$total))))
  }
  
  # ggplot
  if (T) {
    shape <- table(ggdat$marker)
    shape <- data.frame(marker=names(shape),
                        number=as.numeric(shape))
    ggdat$Miss_in_n_cell <- shape[match(ggdat$marker, shape$marker), 2]
    ggdat$Miss_in_n_cell <- factor(ggdat$Miss_in_n_cell)
    table(ggdat$Miss_in_n_cell)
    
    ggplot(data=ggdat)+
      geom_line(aes(x=number, y=ARI, group=1), size=0.8)+
      geom_point(aes(x=number, y=ARI, size=Miss_in_n_cell))+
      xlab("")+
      ylab("ARI value")+
      geom_label(aes(x=number, y=ARI-0.01, fill = marker, alpha = 0.5), label=ggdat$marker, size = 4)+
      facet_grid(cell~.)+
      theme_bw()+
      theme(axis.text.x = element_text(size = rel(1.4)),
            axis.text.y = element_text(size = rel(1.3)),
            legend.title = element_text(size = rel(1.3)),
            legend.text = element_text(size = rel(1.3)),
            legend.position = "top",
            strip.text = element_text(size = rel(1.3))) + 
      guides(alpha = "none", fill = "none")
    
    ggsave("Overall_tendency.png", height = 10, width = 15)
  }
}

# each_marker_ARI_plot
if (T) {
  # prepare for ggdat
  if (T) {
    ggdat <- melt(dat, id.vars = c("cell", "number", "marker"), measure.vars = "ARI")
    n <- as.numeric(unique(gsub("no","",ggdat$number)))
  }
  
  # sort
  if (T) {
    ggdat$number <- factor(ggdat$number,levels = paste0("no", sort(n,decreasing = T)))
  }
  
  # ggplot2
  if (T) {
    ggplot(data=ggdat)+
      geom_line(aes(x=number, y=value, colour=cell, group = cell), size=1)+
      geom_point(aes(x=number, y=value, colour=cell, group = cell), size=2)+
      xlab("")+
      ylab("ARI")+
      facet_wrap(~marker,ncol=4)+
      theme_bw()+
      theme(axis.text.x = element_text(size = rel(1.3), angle = 45, hjust=1, vjust=1),
            axis.text.y = element_text(size = rel(1.3)),
            strip.text  = element_text(size = rel(1.2)),
            legend.position="right", legend.background = element_rect(colour="black", size=1),
            legend.text = element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.3))
      )
    
    # save plot
    ggsave(filename="each_marker_ARI_plot_facet.png", height=10, width=20)
  }
}

