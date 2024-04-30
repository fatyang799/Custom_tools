# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
  library(ggpubr)
  library(reshape2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "27_26_ARI_multi_vs_multi.xls", action = "store",
                help = "The ARI table of 10 times IDEAS results of N-1 markers comparing with 27 markers 30 times IDEAS results [default %default]"),
    
    make_option(c("-o", "--out_tab"), type = "character", default = "mean_compare.xls", action = "store",
                help = "The output file, which record the statistics value for multi_vs_multi comparison for each marker [default %default]"),
    
    make_option(c("-m", "--multi_vs_multi_plot"), type = "character", default = "multi_vs_multi_mean.png", action = "store",
                help = "Provide a boxplot file name. 10 replicates of each marker are compared with 30 replicates of 27 markers, all 300 ARI value as a box. [default %default]"),
    
    make_option(c("-s", "--multi_vs_one_plot"), type = "character", default = "intra_group_compared_with_M27_30times.png", action = "store",
                help = "Provide a boxplot file name. 10 replicates of each marker are compared with 30 replicates of 27 markers, 30 ARI value for a replicate as a box. [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_multi_vs_multi_plot_boxplot.R -i 27_26_ARI_multi_vs_multi.xls -o mean_compare.xls -m multi_vs_multi_mean.png -s intra_group_compared_with_M27_30times.png"
  description_message <- "This Script is to plot multi_VS_multi and multi_VS_one plot for each marker with 10 replicates."
  
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
  input <- "27_25_ARI_multi_vs_multi.xls"
  out_tab <- "mean_compare.xls"
  multi_vs_multi_plot <- "multi_vs_multi_mean.png"
  multi_vs_one_plot <- "intra_group_compared_with_M27_30times.png"
}

# read in the data
if (T) {
  dat <- read.table(input,header = T,sep = "\t")
  rownames(dat) <- dat[,1]
  dat <- dat[,-1]
}

# reshape to long data
if (T) {
  long_dat <- suppressMessages(melt(dat))
  long_dat$Marker <- str_extract(long_dat$variable,"H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?")
  long_dat$No <- str_extract(long_dat$variable,"no[0-9]{1,2}")
  long_dat$No <- factor(long_dat$No,levels = paste0("no",1:10))
}

# mkdir for output dir
if (T) {
  if (! dir.exists(dirname(out_tab))) {
    dir.create(dirname(out_tab))
  }
  if (! dir.exists(dirname(multi_vs_multi_plot))) {
    dir.create(dirname(multi_vs_multi_plot))
  }
  if (! dir.exists(dirname(multi_vs_one_plot))) {
    dir.create(dirname(multi_vs_one_plot))
  }
}

# 方案1：对于需要去除的每个marker的10个重复全部合并作为一个box去比较
if (T) {
  # 计算mean值比较
  if (T) {
    mean <- sort(tapply(long_dat$value, long_dat$Marker, mean))
    ref <- rev(names(mean))[1]
  }
  
  # 计算所有的具体比较值
  if (T) {
    allmarker <- unique(long_dat$Marker)
    
    res <- sapply(allmarker,function(x){
      compare_m <- long_dat[long_dat$Marker==x,2]
      ref_m <- long_dat[long_dat$Marker==ref,2]
      res <- t.test(ref_m,compare_m)
      p <- res$p.value
      t <- res$statistic
      ref_mean <- res$estimate[1]
      compare_mean <- res$estimate[2]
      res <- c(p,t,ref_mean,compare_mean)
    })
    res <- as.data.frame(t(res))
    colnames(res) <- c("P","T","Mean_max","Mean_compare")
    
    res <- round(res,5)
  }
  
  # tab输出
  if (T) {
    res <- cbind(data.frame(File=rownames(res)),res)
    res <- res[order(res$Mean_compare,decreasing = T),]
    
    write.table(res,file = out_tab,sep = "\t",quote = F,row.names = F,col.names = T)
  }
  
  # 画图展示
  if (T) {
    # ggplot statistics paramter
    if (T) {
      # 仅保留P>0.001的在图形上展示
      my_comparisons <- res[res$P>0.001 & res$P!=1,1]
      my_comparisons <- lapply(my_comparisons, function(x){c(ref,x)})
    }
    # sort
    if (T) {
      long_dat$Marker <- factor(long_dat$Marker,levels = res[,1])
    }
    # plot
    if (T) {
      ggboxplot(dat=long_dat,x = "Marker", y = "value",
                color = "Marker",
                legend="none")+
        xlab("")+ylab("")+
        stat_compare_means(comparisons = my_comparisons,method = "t.test")+
        theme(axis.text.x = element_text(size = rel(1.2), angle = 45, hjust = 1, vjust = 1),
              axis.text.y = element_text(size = rel(1.2)))
      ggsave(filename = multi_vs_multi_plot ,width = 20,height = 14,units = "cm")
    }
  }
}

# 方案2：对于需要去除的每个marker的10个重复分别计算一个box去比较
if (T) {
  # 画图
  ggboxplot(dat=long_dat,x = "No", y = "value",
            color = "No",
            legend="none")+
    facet_wrap(~Marker,nrow = 3)+
    xlab("")+ylab("")+
    geom_hline(yintercept = mean(long_dat$value),linetype="dashed",size=0.9,colour="black")+
    theme(axis.text.x = element_text(size = rel(1.2),angle = 90, hjust = 1, vjust = 0.5),
          axis.text.y = element_text(size = rel(1.2)),
          strip.text  = element_text(size = rel(1.2)))
  ggsave(filename = multi_vs_one_plot ,width = 40,height = 14,units = "cm")
}


