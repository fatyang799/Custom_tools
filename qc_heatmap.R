# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(stringr)
  library(reshape2)
  library(optparse)
  suppressPackageStartupMessages(library(ComplexHeatmap))
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The input file, which should be a matrix format with rownames and colnames. [default %default]"),
    
    make_option(c("-o", "--output_pic"), type = "character", default = NULL, action = "store",
                help = "The output figure file name [default %default]"),
    
    make_option(c("-x", "--x_name"), type = "character", default = NULL, action = "store",
                help = "The file record the x label in the figure. The order of the x_name should be same as the column of input [default %default]"),
    
    make_option(c("-y", "--y_name"), type = "character", default = NULL, action = "store",
                help = "The file record the y label in the figure. The order of the y_name should be same as the column of input [default %default]"),
    
    make_option(c("-T", "--heatmap_title"), type = "character", default = "The ARI between 10 replicate runs", action = "store",
                help = "The title of heatmap [default %default]"),
    
    make_option(c("-l", "--legend_title"), type = "character", default = "ARI", action = "store",
                help = "The title of legend [default %default]"),
    
    make_option(c("-L", "--Lower_col"), type = "double", default = 0.8, action = "store",
                help = "The lower value. The color correspond to this value is white [default %default]"),
    
    make_option(c("-U", "--Upper_col"), type = "double", default = 1, action = "store",
                help = "The upper value. The color correspond to this value is red [default %default]"),
    
    make_option(c("-c", "--cell_font"), type = "double", default = 10, action = "store",
                help = "The font size of cell, which contain the specific ARI value [default %default]"),
    
    make_option(c("-s", "--sep"), type = "character", default = "\t", action = "store",
                help = "The field separator character. Note: if the character has '\', then add a quote, write as -s '\\t' [default '\\t']"),
    
    make_option(c("-H", "--header"), type = "logical", default = TRUE, action = "store_false",
                help = "The \"header\" argument in \"read.table\" function in R. Used to read the file in R. If set this, this means \"header=F\" [default %default]"),
    
    make_option(c("-m", "--comment_char"), type = "character", default = "", action = "store",
                help = "The \"comment.char\" argument in \"read.table\" function in R. Used to read the file in R [default \"%default\"]"),
    
    make_option(c("-w", "--width"), type = "double", default = 8, action = "store",
                help = "The \"width\" argument in \"ggsave\" function in R. Used to save the figure in R [default %default]"),
    
    make_option(c("-t", "--height"), type = "double", default = 7, action = "store",
                help = "The \"height\" argument in \"ggsave\" function in R. Used to save the figure in R [default %default]"),
    
    make_option(c("-u", "--units"), type = "character", default = "in", action = "store",
                help = "The \"units\" argument in \"ggsave\" function in R. Used to save the figure in R [default '%default']")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript qc_heatmap.R -i paired_ARI_H9.tab -o paired_ARI_H9_heatmap.png"
  description_message <- "This Script is to plot heatmap"
  
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
  input <- "3.IMR90/paired_ARI_IMR90.tab"
  output <- "3.IMR90/paired_ARI_IMR90.png"
}

# get info
if (T) {
  dat <- read.table(file = input, header = header, sep = sep, fill = T, row.names = 1, comment.char = comment_char) 
  
  # change name
  if (T) {
    if (exists("x_name")) {
      x_name <- read.table(x_name, header = F, sep = "\t", quote = F, fill = T, comment.char = "")[,1]
      colnames(dat) <- x_name
    }
    
    if (exists("y_name")) {
      y_name <- read.table(y_name, header = F, sep = "\t", quote = F, fill = T, comment.char = "")[,1]
      rownames(dat) <- y_name
    }  
  }
}

# heatmap
if (T) {
  ht <- Heatmap(as.matrix(dat), name = legend_title,
                column_title = heatmap_title,
                cell_fun = function(j, i, x, y, width, height, fill) {
                  grid.text(sprintf("%.2f", dat[i, j]), x, y, gp = gpar(fontsize = cell_font))
                },
                border_gp = gpar(col = "black"),
                rect_gp = gpar(col = "black"),
                col = circlize::colorRamp2(c(Lower_col, Upper_col), colors = c("white", "red")),
                cluster_rows = F, cluster_columns = F, 
                row_names_side = "left", column_names_side = "bottom",
                heatmap_legend_param = list(border = T))
  
  png(output_pic, width = width, height = height, units = "in", res = 150)
  draw(ht)
  dev.off()
}

