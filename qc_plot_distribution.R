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
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file, which has at least one column value data to plot [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "density.png", action = "store",
                help = "Output figure file [default %default]"),
    
    make_option(c("-H", "--header"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether the input file has header [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character [default \"\\t\"]"),
    
    make_option(c("-v", "--value"), type = "integer", default = 1, action = "store",
                help = "Which column of file record the value [default %default]"),
    
    make_option(c("-x", "--xlim"), type = "integer", default = NULL, action = "store",
                help = "The xlim in ggplot2, if not set, then program will automatically decide [default %default]"),
    
    make_option(c("-t", "--title"), type = "character", default = NULL, action = "store",
                help = "The title in ggplot2, if not set, then no title will shows [default %default]"),
    
    make_option(c("-X", "--x_axis_title"), type = "character", default = NULL, action = "store",
                help = "The x_axis_title in ggplot2, if not set, then no title will shows [default %default]"),
    
    make_option(c("-l", "--logx"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether transfer to log scale [default %default]"),
    
    make_option(c("-w", "--width"), type = "numeric", default = 9, action = "store",
                help = "The output figure width size [default %default]"),
    
    make_option(c("-e", "--height"), type = "numeric", default = 9, action = "store",
                help = "The output figure height size [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_plot_distribution.R -i statistics.txt -o ARI.png"
  description_message <- "This Script is to plot a data distribution plot, also called density plot."
  
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
  xlim_judge <- ifelse("xlim" %in% ls(),T,F)
  x_axis_title_judge <- ifelse("x_axis_title" %in% ls(),T,F)
  title_judge <- ifelse("title" %in% ls(),T,F)
}

# read data
if (T) {
  dat <- data.table::fread(input, header = header, sep=sep, data.table=F)[,value]
  dat <- data.frame(signal=dat)
}

# ggplot
if (T) {
  if (logx) {
    p <- ggplot(dat) +
      geom_density(aes(x=log(signal)), size=1, linetype = 1, fill="#bdbdbd")
  }
  if (! logx) {
    p <- ggplot(dat) +
      geom_density(aes(x=signal), size=1, linetype = 1, fill="#bdbdbd")
  }
  
  if (xlim_judge) {
    p <- p+scale_x_continuous(limits = c(0,xlim))
  }
  
  if (x_axis_title_judge) {
    p <- p+xlab(x_axis_title)
  }
  
  if (title_judge) {
    p <- p+labs(title=title)
  }
  
  p <- p + theme(axis.title = element_text(size = rel(1.2)),
                 axis.text = element_text(size = rel(1.2))) + theme_bw()
}

# save
if (T) {
  ggsave(plot=p, file=output, width = width, height = height)
}

