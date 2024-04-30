# load environment
if (T) {
  library(stringr)
}

# get data from snakemake
if (T) {
  input <- snakemake@input[[1]]
  output_withCT <- snakemake@output$withCT
  output_withoutCT <- snakemake@output$withoutCT
  
  cell_line <- snakemake@params$cell_line
  exp_root <- snakemake@params$exp_root
  ct_root <- snakemake@params$ct_root
}

# test data
if (F) {
  input <- "H9/EXP/Exp_CT_list.txt"
  output_withCT <- "H9/EXP/withCT_metadata.txt"
  output_withoutCT <- "H9/EXP/withoutCT_metadata.txt"
  
  cell_line <- "H9"
  exp_root <- "normalization7/1.selected_data/2.bigwig"
  ct_root <- "deeptools6/1.bigwig"
}

# format dat
if (T) {
  input <- read.table(input, header = F, sep = "\t")
}

# get additional info
if (T) {
  id <- tolower(cell_line)
  marker <- str_extract(input[,1], "H[1-4][AB]?[A-Za-z][A-Z]?[0-9]{0,3}[A-Za-z]{0,3}[0-9]?")
}

# construct dataframe
if (T) {
  exp <- paste0(exp_root,"/",marker,".bw")
  ct <- paste0(ct_root,"/",input[,2],".bw")
  meta <- data.frame(cell = cell_line,
                     marker = marker,
                     id = id,
                     exp = exp,
                     ct = ct)
}

# output
if (T) {
  # withoutCT
  write.table(meta[,1:4], file = output_withoutCT, quote = F, row.names = F, col.names = F, sep = "\t")
  # withCT
  write.table(meta, file = output_withCT, quote = F, row.names = F, col.names = F, sep = "\t")  
}

