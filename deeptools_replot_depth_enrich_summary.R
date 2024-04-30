
# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(ggplot2)
}

# get the parameter
if (T) {
  args <- commandArgs(trailingOnly = T)
  input <- args[1]
  out_depth <- args[2]
  out_enrich <- args[3]
}

# read the data
if (T) {
  ggdat <- read.table(input, header = T, sep = "\t", fill = T, comment.char = "")
}

# format the data
if (T) {
  ggdat$Group <- factor(ggdat$Group)
}

# sequence depth
if (T) {
  p <- ggplot(data = ggdat) +
    geom_bar(aes(x = Sample, y = total_passed, fill = Number), stat = "identity") +
    scale_x_discrete(name = "") +
    scale_y_continuous(name = "Number of Reads") +
    facet_wrap(~Group, nrow = 4, scales = "free_x") +
    theme(axis.text.x = element_text(size = rel(1.2), angle = 30, hjust = 1, vjust = 1),
          axis.text.y = element_text(size = rel(1.1), angle = 0),
          axis.title.y = element_text(size = rel(1.2), angle = 90),
          strip.text = element_text(size = rel(1.2), angle = 0),
          legend.position = "none")
  
  ggsave(plot = p, filename = out_depth, width = 15,height = 8)
}

# signal enrichment
if (T) {
  p <- ggplot(data = ggdat) +
    geom_bar(aes(x = Sample, y = Synthetic.JS.Distance, fill = Number), stat = "identity") +
    scale_x_discrete(name = "") +
    scale_y_continuous(name = "Enrichment level") +
    facet_wrap(~Group, nrow = 4, scales = "free_x") +
    theme(axis.text.x = element_text(size = rel(1.2), angle = 30, hjust = 1, vjust = 1),
          axis.text.y = element_text(size = rel(1.1), angle = 0),
          axis.title.y = element_text(size = rel(1.2), angle = 90),
          strip.text = element_text(size = rel(1.2), angle = 0),
          legend.position = "none")
  
  ggsave(plot = p, filename = out_enrich, width = 15,height = 8)
}

