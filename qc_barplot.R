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
    make_option(c("-i", "--input"), type = "character", default = "stat.txt", action = "store",
                help = "The input file, which must includ identity value (-b) and sample label (-a). The group info is not necessary, which record the grouping of sample labels [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = F, action = "store_true",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=T\" [default %default]"),
    
    make_option(c("-a", "--sample_label"), type = "integer", default = 1, action = "store",
                help = "Which column record the [sample label]/[x axis label] [default %default]"),
    
    make_option(c("-b", "--value"), type = "integer", default = 2, action = "store",
                help = "Which column of file record the value [default %default]"),
    
    make_option(c("-d", "--display_numer"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether to show number within barplot [default %default]"),
    
    make_option(c("-g", "--group"), type = "integer", default = NULL, action = "store",
                help = "The column record the group info, which is used to facet by ggplot. Not necessary [default %default]"),
    
    make_option(c("-n", "--facet_n_col"), type = "integer", default = 4, action = "store",
                help = "How many column are used to facet by ggplot [default %default]"),
    
    make_option(c("-x", "--title_x"), type = "character", default = "Title_X", action = "store",
                help = "The titile for x axis within ggplot2 [default %default]"),
    
    make_option(c("-y", "--title_y"), type = "character", default = "Title_Y", action = "store",
                help = "The titile for y axis within ggplot2 [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "stat_barplot.png", action = "store",
                help = "The output file [default %default]"),
    
    make_option(c("-w", "--width"), type = "integer", default = 12, action = "store",
                help = "Which column of file record the value [default %default]"),
    
    make_option(c("-e", "--height"), type = "integer", default = 8, action = "store",
                help = "Which column of file record the value [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_barplot.R -i meta.txt -H -s \"\\t\" -a 1 -b 2 -g 3 -d -n 7 -x \"Cell\" -y \"Percentage\" -o 0_percentage.png"
  description_message <- "This Script is to plot barplot."
  
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
  input <- "ideas_peak_number.txt"
  sep <- "\t"
  header <- F
  sample_label<- 1
  value <- 3
  
  display_numer <- T
  
  group <- 2
  facet_n_col <- 7
  
  title_x <- "Cell"
  title_y <- "Genomic Percentage of Peaks"
  
  output <- "barplot.png"
  width <- 12
  height <- 8
}

# read data
if (T) {
  input <- data.table::fread(input, header = header, sep = sep, data.table = F)
  if (exists("group")) {
    dat <- input[,c(sample_label, group, value)]
    colnames(dat) <- c("Name", "Group", "Value")  
  }
  if (!exists("group")) {
    dat <- input[,c(sample_label, value)]
    colnames(dat) <- c("Name", "Value")
  }
}

# sort
if (T) {
  dat <- dat[order(dat$Value,decreasing = T),]
  dat$Name <- factor(dat$Name,levels = unique(dat$Name))
}

# ggplot
if (T) {
  p <- ggplot(dat)+
    geom_bar(aes(x=Name,y=Value),stat="identity")+
    xlab(title_x)+
    ylab(title_y)+
    theme(axis.title = element_text(size = rel(1.4)),
          axis.text = element_text(size = rel(1.2)),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
          legend.text = element_text(size = rel(1.2)),
          legend.title = element_text(size = rel(1.2)),
          strip.text = element_text(size = rel(1.2)))
  
  # show number on the bar
  if (display_numer) {
    p <- p + geom_text(aes(x=Name, y=Value, label=round(Value, 2)), vjust=1, size=3, colour="white")
  }
  
  # facet
  if (exists("group")) {
    p <- p + facet_wrap(~Group, ncol=facet_n_col)
  }
  
  # output picture file
  ggsave(plot=p, filename = output, width = width, height = height)
}
