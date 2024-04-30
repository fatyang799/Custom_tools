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
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file, which is the **paired intra ARI matrix** [default %default]"),
    
    make_option(c("-o", "--output_tab"), type = "character", default = NULL, action = "store",
                help = "The output results dataframe. It has 7 column: Filename, Mean ARI value, Median ARI value, Overall Mean ARI, Overall Median ARI, diff of Mean ARI and diff of Median ARI [default %default]"),
    
    make_option(c("-m", "--boxplot_mean_file"), type = "character", default = NULL, action = "store",
                help = "The output boxplot, which sort the box by diff between mean ari of each file and overall ari mean [default %default]"),
    
    make_option(c("-M", "--boxplot_median_file"), type = "character", default = NULL, action = "store",
                help = "The output boxplot, which sort the box by diff between median ari of each file and overall ari median [default %default]"),
    
    make_option(c("-d", "--overall_density_file"), type = "character", default = NULL, action = "store",
                help = "The overall ARI density distribution figure [default %default]"),
    
    make_option(c("-y", "--yLim"), type = "character", default = "auto", action = "store",
                help = "The boxplot y scale. You can specify the scale for y axis by \"min:max\" or \"auto\". e.g. -y 0.5:1 [default %default]"),
    
    make_option(c("-r", "--row_names"), type = "double", default = 1, action = "store",
                help = "A single number giving the column of the table which contains the row names.If no rowname column, you can set this as NULL [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]"),
    
    make_option(c("-c", "--comment_char"), type = "character", default = "", action = "store",
                help = "The \"comment.char\" argument in \"read.table\" function in R. Used to read the file in R [default %default]")
    
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_get_representative.R -i paired_ARI.tab -o ARI_of_markers.txt -m 1.mean_ARI_boxplot.png -M 2.median_ARI_boxplot.png -d 3.overall_ARI_density.png"
  description_message <- "This Script is to get a representative ideas, which represents all ideas outputs with same input data and same code."
  
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
  input <- "paired_ARI_H1.tab"
  header <- T
  row_names <- 1
  sep <- "\t"
  comment_char <- ""
  yLim <- "0.5:1"
}

# intra group ARI
if (T) {
  cor <- read.table(input, header = header, row.names = row_names, sep = sep, comment.char = comment_char)
  intra <- c()
  for (i in 1:ncol(cor)) {
    x <- cor[,i]
    n=which(x==1)
    if(n!=1){
      intra <- c(intra,x[1:n-1])
    }
  }
  intra_mean <- mean(intra)
  intra_med <- median(intra)
}

# calculate mean and median value of ARI for each file
if (T) {
  sep_mean <- apply(cor, 1, function(x){
    mean(x[x!=1])
  })
  ord <- sort(abs(sep_mean-intra_mean))
  print(paste0("The mean of ARI of ", names(ord)[1]," compared with others is most close to the whole"))
  
  sep_med <- apply(cor, 1, function(x){
    median(x[x!=1])
  })
  ord <- sort(abs(sep_med-intra_med))
  print(paste0("The median of ARI of ", names(ord)[1]," compared with others is most close to the whole"))
}

# boxplot for all ARI
if (T) {
  # wide to long data
  if (T) {
    boxdat <- cor
    boxdat <- melt(boxdat)  
    boxdat <- boxdat[boxdat$value!=1,]
  }
  
  # sort by mean
  if (T) {
    ord <- names(sort(abs(sep_mean - intra_mean)))
    boxdat$variable <- factor(boxdat$variable, levels = ord)
    
    # ggplot
    p <- ggplot(data = boxdat) + 
      geom_boxplot(aes(x = variable, y = value, color = variable)) +
      labs(x="", y="Similarity between data", title="Sort_by_Mean")+
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.4)),
            axis.text.y = element_text(size = rel(1.4)),
            legend.position = "none")
    
    line_num <- intra_mean
    p <- p + geom_hline(yintercept=line_num,linetype="dashed",alpha=0.5)
    
    modify_ylim <- ifelse(yLim == "auto", F, T)
    if (modify_ylim) {
      yLim <- str_split(yLim, ":")
      yLim <- do.call(c, yLim)
      yLim <- as.numeric(yLim)
      p <- p + ylim(yLim)
    }
    
    ggsave(plot = p, filename = boxplot_mean_file, width = 15, height = 10, units = "cm")
  }
  
  # sort by median
  if (T) {
    ord <- names(sort(abs(sep_med - intra_med)))
    boxdat$variable <- factor(boxdat$variable, levels = ord)
    
    # ggplot
    p <- ggplot(data = boxdat) + 
      geom_boxplot(aes(x = variable, y = value, color = variable)) +
      labs(x="", y="Similarity between data", title="Sort_by_Median")+
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.4)),
            axis.text.y = element_text(size = rel(1.4)),
            legend.position = "none")
    
    line_num <- intra_med
    p <- p + geom_hline(yintercept=line_num,linetype="dashed",alpha=0.5)
    if (modify_ylim) {
      p <- p + ylim(yLim)
    }
    
    ggsave(plot = p, filename = boxplot_median_file, width = 15, height = 10, units = "cm")
  }
}

# distribution for all ARI
if (T) {
  dat <- data.frame(signal=intra)
  ggplot(dat)+
    geom_histogram(aes(x=signal,y=..density..),bins=30,alpha=0.25)+
    geom_density(aes(x=signal),size=0.8,linetype = 1)+
    geom_vline(xintercept=intra_mean, linetype=1, alpha=0.5)+
    geom_vline(xintercept=intra_med, linetype=2, alpha=0.5)+
    xlab("")+ylab("")+
    theme_bw()+
    theme(axis.text.x = element_text(size = rel(1.4)),
          axis.text.y = element_text(size = rel(1.4)))
  
  ggsave(filename = overall_density_file, width = 10, height = 10, units = "cm")
}

# integrate all results
if (T) {
  result <- data.frame(file=rownames(cor),
                       mean=sep_mean,
                       median=sep_med,
                       overall_mean=intra_mean,
                       overall_median=intra_med)
  
  # calculate absolute difference
  result$abs_diff_mean <- abs(result$mean-result$overall_mean)
  result$abs_diff_median <- abs(result$median-result$overall_median)
  
  # reorder_by_mean
  result <- result[order(result$abs_diff_mean),]
  
  # rounding
  result[,2:ncol(result)] <- round(result[,2:ncol(result)],4)
}

# output results
if (T) {
  write.table(result, file = output_tab, row.names = F, col.names = T, sep = "\t", quote = F)
}



