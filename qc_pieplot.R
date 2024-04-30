# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "procent.txt", action = "store",
                help = "The input file. 1st column is the label, 2nd column is the absolute numer [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "pie.png", action = "store",
                help = "The output file name [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether the input file has header [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character [default \"\\t\"]"),
    
    make_option(c("-w", "--width"), type = "integer", default = 8, action = "store",
                help = "Manual option for determining the output file width in inches. [default %default]"),
    
    make_option(c("-e", "--height"), type = "integer", default = 6, action = "store",
                help = "Manual option for determining the output file height in inches. [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_pieplot.R -i meta.txt -o pie_plot.png"
  description_message <- "This Script is to plot pie plot."
  
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
  input <- "pro.txt"
  output <- "pie.png"
  header <- F
  sep <- "\t"
  width <- 8
  height <- 6
}

# read data
if (T) {
  dat <- read.table(input, header = header, sep = sep)
  
  if (! header) {
    colnames(dat) <- c("group", "value")
  }
}

# Compute the procentage
if (T) {
  dat$group <- factor(dat$group, levels = dat$group)
  dat$prop <- dat$value / sum(dat$value) *100
}

# Basic piechart
if (T) {
  ggplot(dat, aes(x="", y=prop, fill=group)) +
    geom_bar(stat="identity", width=1, color="black") +
    coord_polar("y", start=0) +
    scale_fill_brewer(palette="Set1", 
                      labels=paste0(dat$group, ": ", round(dat$prop, 2), "%")) + 
    theme_void() +
    theme(legend.text = element_text(size = rel(1.2)),
          legend.title = element_text(size = rel(1.4)))
  
  ggsave(filename = output, width = width, height = height)
}

