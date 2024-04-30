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
    make_option(c("-i", "--input"), type = "character", default = "M-bias.txt", action = "store",
                help = "The ggplot2 input file, with x value labeled position, y value labeled Methy_Level, \nC context type labeled group1, R1/R2 labeled group2 [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "M-bias.png", action = "store",
                help = "The output file"),
    
    make_option(c("-w", "--width"), type = "numeric", default = 12, action = "store",
                help = "The output figure width size [default %default]"),
    
    make_option(c("-H", "--height"), type = "numeric", default = 8, action = "store",
                help = "The output figure height size [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript bismark_plot_mbias.R -i M-bias.txt -o M-bias.png"
  description_message <- "This Script is to plot M-bias with bismark."
  
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
  input <- "H9_WGBS_rep1.deduplicated.M-bias.png.txt"
  output <- "H9_WGBS_rep1.deduplicated.M-bias.png"
  width = 12
  height = 8
}

# read the data
if (T) {
  dat <- read.table(input, header = T, sep = "\t", fill = T, comment.char = "")
  
  type <- grepl("_R1$|_R2$", dat$Type)
  PE_torf <- sum(type) == nrow(dat)
  if (PE_torf) {
    dat$group1 <- str_split(dat$Type, "_", simplify = T)[,1]
    dat$group2 <- str_split(dat$Type, "_", simplify = T)[,2]
  }
  colnames(dat)[4] <- "Methy_Level"
  
  dat$position <- as.numeric(dat$position)
}

# ggplot2
if (T) {
  head(dat)
  
  label <- c(
    seq(min(dat$position), min(dat$position)+8, 2),
    seq(min(dat$position)+9, max(dat$position)-9, 10),
    seq(max(dat$position)-9, max(dat$position), 2),
	max(dat$position)
  )
  label <- unique(label)
  
  if (PE_torf) {
    p <- ggplot(data = dat)+
      geom_line(aes(x=position, y=Methy_Level, group=Type, color=group2), linewidth=0.8)+
      scale_x_continuous(breaks = label)+
      facet_grid(group1~.)+
      theme(axis.title = element_text(size = rel(1.2)),
            axis.text.x = element_text(size = rel(1.2), angle = 90, hjust = 1, vjust = 0.5),
            axis.text.y = element_text(size = rel(1.2)),
            legend.text = element_text(size = rel(1.2)),
            legend.title = element_text(size = rel(1.2)),
            legend.position = "top",
            strip.text = element_text(size = rel(1.2)))
  }
  if (! PE_torf) {
    p <- ggplot(data = dat)+
      geom_line(aes(x=position, y=Methy_Level, group=Type), linewidth=0.8)+
      scale_x_continuous(breaks = label)+
      facet_grid(Type~.)+
      theme(axis.title = element_text(size = rel(1.2)),
            axis.text.x = element_text(size = rel(1.2), angle = 90, hjust = 1, vjust = 0.5),
            axis.text.y = element_text(size = rel(1.2)),
            legend.position = "none",
            strip.text = element_text(size = rel(1.2)))
  }
}

# save the output
ggsave(plot = p, filename = output, width = width, height = height)


