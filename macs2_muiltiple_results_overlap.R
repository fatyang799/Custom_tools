# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
  suppressPackageStartupMessages(library(GenomicRanges))
  suppressPackageStartupMessages(library(cowplot))
  suppressPackageStartupMessages(library(ggplotify))
  suppressPackageStartupMessages(library(UpSetR))
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input_list"), type = "character", default = "file.txt", action = "store",
                help = "The input file, which record a series of output *narrowPeak files to be compared  [default %default]"),
    
    make_option(c("-w", "--windows"), type = "character", default = "windowsNoBlack.withid.bed", action = "store",
                help = "The input file, which record a series of output *narrowPeak files to be compared  [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "overlap.png", action = "store",
                help = "Output figure file [default %default]"),
    
    make_option(c("-W", "--width"), type = "numeric", default = 10, action = "store",
                help = "The output figure width size [default %default]"),
    
    make_option(c("-H", "--height"), type = "numeric", default = 6, action = "store",
                help = "The output figure height size [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript macs2_muiltiple_results_overlap.R -i file.txt -o overlap.png"
  description_message <- "This Script is to plot a upsetR plot for serveral narrowPeak files."
  
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
  input_list <- "file.txt"
  windows <- "windowsNoBlack.withid.bed"
  output <- "overlap.png"
  width <- 10
  height <- 6
}

# get all files
if (T) {
  files <- read.table(input_list, header = F)[, 1]
  windows <- data.table::fread(windows, header = F, data.table = F)
  windows <- GRanges(seqnames = windows[,1],
                     ranges = IRanges(start = windows[,2]+1,
                                      end = windows[,3]),
                     ID = windows[,4])
  
  dat <- lapply(files, function(x) {
    # x <- files[1]
    dat <- read.table(x, header = F, sep = "\t", fill = T, comment.char = "")
    dat$fdr <- str_extract(x, "fdr_0.0[0-9]{1,3}")
    dat <- GRanges(seqnames = dat[,1],
                   ranges = IRanges(start = dat[,2]+1,
                                    end = dat[,3]),
                   ID = dat[,4],
                   FDR = dat$fdr)
    n <- length(dat)
    return(list(dat, n))
  })
  
  data <- lapply(dat, function(x) x[[1]])
  data <- GRangesList(data)
  names(data) <- str_extract(files, "fdr_0.0[0-9]{1,3}")
}

# get overlap info
if (T) {
  overlap <- lapply(data, function(x) {
    windows$ID[windows %over% x]
  })
}

pdf(NULL)

# get upsetR plot
if (T) {
  p1 <- upset(fromList(overlap), nsets = 4, mb.ratio = c(0.7, 0.3),
              text.scale = c(2, 1.5, 1.5, 1.2, 1.5, 1.5),
              order.by = "freq", decreasing = T)
}

# get peak number barplot
if (T) {
  ggdat <- sapply(dat, function(x) x[[2]])
  ggdat <- data.frame(File = str_extract(files, "fdr_0.0[0-9]{1,3}"),
                      Peak_num = ggdat)
  ggdat$File <- factor(ggdat$File, levels = paste0("fdr_", c(0.001, 0.005, 0.01, 0.05)))
  
  p2 <- ggplot(data = ggdat) +
    geom_bar(aes(x=File, y=Peak_num, fill=File), stat = "identity") +
    geom_text(aes(x=File, y=Peak_num+1000, label=Peak_num)) +
    xlab(NULL) +
    theme(axis.title = element_text(size = rel(1.2)),
          axis.text = element_text(size = rel(1.1)),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
          legend.position = "none")
}

# merge figure
if (T) {
  p3 <- as.ggplot(p1)
  
  p4 <- ggdraw(p3) +
    draw_plot(p2, x=0.65, y=0.58, width = 0.35, height = 0.4)
}

# save the figure
ggsave(filename = output, plot = p4, width = width, height = height)

