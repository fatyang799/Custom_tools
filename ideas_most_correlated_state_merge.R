# manual:
#   Rscript ideas_correlation_merge.R cor.tab awk_script replacement.tab
#     - cor.tab: the pearson correlation between various state
#     - cor_cutoff: the pearson correlation cutoff. if the cor between 2 state above this cutoff, then 2 state will be merged
#     - awk_script: the output script for integrate most correlated state into one state name
#     - replacement.tab: the detailed merge state
#
# For example:
#   Rscript ideas_correlation_merge.R cor.tab awk_cor_state.sh
#
# Output:
#   - awk_cor_state.sh: awk command for downstream analysis. 
#                       Integrate most correlated state into one state name
#   - replacement.tab: the detailed merge state



# options receiving
if (T) {
  args <- commandArgs(trailingOnly=TRUE)
  cor_file <- args[1]
  cor_cutoff <- as.numeric(args[2])
  script <- args[3]
  tab <- args[4]
}

# load environment
if (T) {
  options(stringAsFactors = F)
  options(warn =-1)
  library(stringr)
}

# read data
if (T) {
  dat <- read.table(cor_file,header = F,sep = "\t",fill = T)
  colname <- as.character(dat[1,1:(ncol(dat)-1)])
  rowname <- as.character(dat[2:nrow(dat),1])
  dat <- dat[-1,-1]
  dat <- as.data.frame(sapply(dat, as.numeric))
  colnames(dat) <- colname
  rownames(dat) <- rowname
}

if (sum(dat>cor_cutoff)>nrow(dat)) {
  # correlation
  if (T) {
    # pass filter values
    if (T) {
      pass_filter <- dat>cor_cutoff
      pass_filter <- apply(pass_filter, 1, function(x){
        n <- which(x)
        ifelse(length(n)>1,length(n)-1,0)
      })
      pass_filter <- pass_filter[pass_filter>0]
      pass_filter
    }
    
    # statistics combination
    if (T) {
      combination <- sapply(names(pass_filter), function(state){
        cor <- dat[,state]
        rownames(dat)[sort(cor,decreasing = T)[2]==cor]
      })
      combination <- data.frame(source=names(combination),
                                target=combination)
      
      # 这里的sort方案要与下面的linux部分的排序方案保持一致
      combination <- as.data.frame(t(apply(combination, 1, sort)))
      colnames(combination) <- c('source','target')
      
      # deduplicated
      combination <- combination[!duplicated(paste0(combination[,1],combination[,2])),]
      combination$correlation <- sapply(1:nrow(combination), function(x){
        row=combination$source[x]
        col=combination$target[x]
        dat[row,col]
      })
    }
    
    # sort to facilitate the downstream linux code
    if (T) {
      combination <- combination[order(combination[,1]),]
    }
  }
  
  # awk code
  if (T) {
    # awk command template
    # awk -F" " '{if ($5=="1") {statement1} else if ($5=="2") {statement2} ... else {statementN}}' file
    
    # Manual
    manual <- "# usage: bash this_script.sh IDEAS_output.state > New.state\n"
    
    source <- as.numeric(gsub("State","",str_split(combination$source," ",simplify = T)[,1]))
    target <- as.numeric(gsub("State","",str_split(combination$target," ",simplify = T)[,1]))
    
    start <- "awk -F\" \" \'{"
    if_c <- paste(" if ($5==\"",source,"\") {print $1,$2,$3,$4,",target,",$6} else",sep = "",collapse = "")
    else_c <- paste(start,if_c," {print $1,$2,$3,$4,$5,$6}",sep = "")
    command <- paste(else_c," }\' $1",sep = "")
  }
  
  # output
  if (T) {
    # command
    write(manual,file = script)
    write(command,file = script,append = T)
    # tab
    write.table(combination,file = tab,quote = F,row.names = F,col.names = T,sep = "\t")
  }
} else {
  cat(paste0("No correlation between states are more than ",cor_cutoff," in ",cor_file," file!\tPlease Note the ",cor_file," file!\n"))
}
