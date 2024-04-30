# manual:
#   Rscript ideas_integrate_nmi_ari.R file_list paired_intra sort_m decreasing output.tab output.pdf
#     - file_list: a file list containing the file need to be compared (ri_ari_ref_target.xls)
#     - paired_intra: a reference file (paired_ARI.tab)
#     - sort_m: how to sort the boxplot. you can select one from ["mean","abs_diff","p","t"].recommend "mean"
#     - decreasing: decreasing or not. recommend T
#     - output.tab: the statistics value for each marker if removed.
#     - output.pdf: the boxplot for each marker if removed.
#
# File example:
#     - one file from file_list (tab sep):
#         reference     target                ri    ari
#         no1.state     remove_H2AFZ.state    0.95  0.90
#
#     - paired_intra (tab sep):
#                   no1.state no2.state no3.state
#         no1.state       1.0       0.9       0.3
#         no2.state       0.9       1.0       0.8
#         no3.state       0.3       0.8       1.0
#
# Usage example:
#   Rscript ideas_integrate_nmi_ari.R file.txt paired_ARI.tab mean T remove_marker_statistics.xls remove_marker_statistics.pdf
#
# Output:
#   - remove_marker_statistics.xls: the statistics value for each marker if removed, which include T, p, mean, abs_diff
#   - remove_marker_statistics.pdf: the boxplot for each marker if removed


# options receiving
if (T) {
  args <- commandArgs(trailingOnly=TRUE)
  file_list <- args[1]
  paired_intra <- args[2]
  sort_m <- toupper(args[3])
  decreasing <- args[4]
  output_tab <- args[5]
  output_pdf <- args[6]
}

# load environment
if (T) {
  options(stringAsFactors = F)
  options(warn =-1)
  library(stringr)
  library(ggplot2)
  library(ggpubr)
}

# format options
if (T) {
  # file list
  file_list <- read.table(file_list,header = F)[,1]
  # decreasing
  decreasing <- ifelse("T"==toupper(decreasing)|"TRUE"==toupper(decreasing),T,F)
}

# read in data
if (T) {
  # intergroup ARI
  if (T) {
    dat <- lapply(file_list,function(x){
      read.table(x,header = T,sep = "\t")[,c(2,4)]
    })
    dat <- do.call(rbind,dat)
    dat$source <- rep(file_list,each=nrow(dat)/length(file_list))  
  }
  
  # intragroup ARI
  if (T) {
    intra <- read.table(paired_intra,header = T,row.names = 1,sep = "\t")
    tmp <- c()
    for (i in 1:ncol(intra)) {
      x <- intra[,i]
      n=which(x==1)
      if(n!=1){
        tmp <- c(tmp,x[1:n-1])
      }
    }
    intra <- tmp
    rm(tmp)
  }
}

# format date
if (T) {
  dat$target <- str_extract(dat$target,pattern = "H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?")
  dat$source <- str_extract(dat$source,pattern = "no[0-9]{1,2}")
  dat <- dat[,c(3,1,2)]
  colnames(dat) <- c('source','target','value')
  
  intra <- data.frame(source="intra",
                      target="intra",
                      value=intra)
  dat <- rbind(intra,dat)
}

# statistics for compare_means
if (T) {
  # 计算去除每个marke后改变的T检验中T和P值、ari均值以及与组内intra之间的差值绝对值
  if (T) {
    res <- tapply(dat$value, dat$target, function(x){
      # x <- dat[dat$target=="H3K4me3",3]
      res <- t.test(x,intra$value)
      t <- res$statistic
      p <- res$p.value
      m <- mean(x)
      c(t,p,m)
    })
    res <- do.call(rbind,res)
    colnames(res) <- c("T","P","Mean")
    res <- as.data.frame(res)
    res$abs_diff <- abs(res$Mean-res["intra","Mean"])
  }
  
  # 排序设置
  if (T) {
    if (sort_m=="MEAN") {
      res <- res[order(res$Mean,decreasing = decreasing),]
    } else if (sort_m=="ABS_DIFF") {
      res <- res[order(res$abs_diff,decreasing = decreasing),]
    } else if (sort_m=="P") {
      res <- res[order(res$P,decreasing = decreasing),]
    } else if (sort_m=="T") {
      res <- res[order(res$T,decreasing = decreasing),]
    }
  }
  
  # 输出结果文件
  if (T) {
    # res <- round(res,5)
    tab <- res
    tab$marker <- rownames(tab)
    tab <- tab[,c(5,1:4)]
    write.table(tab,file = output_tab,sep = "\t",quote = F,row.names = F,col.names = T)
  }
}

# ggplot statistics paramter
if (T) {
  # boxplot排序设置
  dat$target <- factor(dat$target,levels = rownames(res))
  # 仅保留P>0.001的在图形上展示
  res <- res[res$P>0.001 & res$P!=1,]
  my_comparisons <- lapply(rownames(res), function(x){c("intra",x)})
}

# ggplot
if (T) {
  ggboxplot(dat=dat,x = "target", y = "value",
            color = "target",
            legend="none")+
    stat_compare_means(comparisons = my_comparisons)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave(output_pdf,width = 20,height = 14,units = "cm")
}

