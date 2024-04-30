# manual:
#   Rscript rand.R ideas1 ideas2 column1 column2 correct
#     - ideas1/2: the output chromatin state of IDEAS
#     - column1/2: the column of chromatin state of IDEAS that record the state number. default 5 5
#     - correct: T/t or F/f. Whether to correct the rand index. T-ARI, F-RI. default F
#
# For example:
#   Rscript rand.R ENCODE_27_Markers_IDEAS_output/ENCODE_27_Markers.state ENCODE_26_Markers_IDEAS_output/ENCODE_26_Markers.state 5 5 T
#
# Output:
#   - normalized_RC_pearson.pdf: the output of correlation heatmap


# options receiving
if (T) {
  args <- commandArgs(trailingOnly=TRUE)
  # ideas1 <- "/public/home/yangliu/Project/ENCODE/8.IDEAS/multiple_time_IDEAS/mycut_0.9/test_1/ENCODE_27_Markers_IDEAS_output/ENCODE_27_Markers.state"
  # ideas2 <- "/public/home/yangliu/Project/ENCODE/8.IDEAS/multiple_time_IDEAS/mycut_0.9/test_2/ENCODE_27_Markers_IDEAS_output/ENCODE_27_Markers.state"
  ideas1 <- args[1]
  ideas2 <- args[2]
  a3 <- args[3]
  a4 <- args[4]
  a5 <- args[5]
  args35 <- c(a3,a4,a5)
}

# manage options
if (T) {
  # default
  correct <- F
  column1 <- "5"
  column2 <- "5"
  # correct from options
  if (sum(grepl("[TFtf]",args35))==1) {
    correct <- args35[grepl("[TFtf]",args35)]
    correct <- ifelse(toupper(correct)=="T" | toupper(correct)=="TRUE",T,F)
  }
  # column from options
  if (sum(grepl("[0-9]",args35))==2) {
    column1 <- args35[grepl("[0-9]",args35)][1]
    column2 <- args35[grepl("[0-9]",args35)][2]
  }
}

# format options
if (T) {
  c1 <- as.numeric(column1)
  c2 <- as.numeric(column2)  
}

# read in data
if (T) {
  i1 <- read.table(ideas1,header = T,sep = " ",comment.char = "")[,c1]
  i2 <- read.table(ideas2,header = T,sep = " ",comment.char = "")[,c2]
}

# rand index
index <- ifelse(correct,flexclust::randIndex(table(i1,i2),correct = T),flexclust::randIndex(table(i1,i2),correct = F))

# output
if (T) {
  message <- ifelse(correct,"The ARI value is ","The RI value is ")
  message <- paste0(message,index)
  print(message)
}
