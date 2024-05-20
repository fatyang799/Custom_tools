

# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(parallel)
  library(pheatmap)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "multiBigwigSummary.tab", action = "store",
                help = "The input file. It should be the output correlation matrix of plotCorrelation [default %default]"),
    
    make_option(c("-g", "--group"), type = "character", default = NULL, action = "store",
                help = "A file record the group info of input samples [default %default]"),
    
    make_option(c("-o", "--output_dir"), type = "character", default = NULL, action = "store",
                help = "The name of output **directory** which store the correltion matrix and heatmap picture [default %default]"),
    
    make_option(c("-c", "--colname"), type = "character", default = NULL, action = "store",
                help = "**Not necessary**. When you want to rename the colname of input, you can provide a file record the colname [default %default]"),
    
    make_option(c("-w", "--width"), type = "integer", default = 14, action = "store",
                help = "Manual option for determining the output file width in inches. [default %default]"),
    
    make_option(c("-H", "--height"), type = "integer", default = 12, action = "store",
                help = "Manual option for determining the output file height in inches. [default %default]"),
    
    make_option(c("-r", "--fontsize_row"), type = "integer", default = 20, action = "store",
                help = "Fontsize for rownames [default %default]"),
    
    make_option(c("-f", "--fontsize_number"), type = "integer", default = 13, action = "store",
                help = "Fontsize of the numbers displayed in cells [default %default]"),
    
    make_option(c("-u", "--upper"), type = "double", default = 1, action = "store",
                help = "The minium of range [default %default]"),
    
    make_option(c("-l", "--lower"), type = "double", default = -1, action = "store",
                help = "The maxium of range [default %default]"),
    
    make_option(c("-n", "--display_numbers"), type = "logical", default = FALSE, action = "store_true",
                help = "Whether to display cor number in cells [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript deeptools_plotcorrelation_by_rawMatrix.R -i multiBigwigSummary.tab -g sample.group -o results/sample1 -u 1 -l -1 -n"
  description_message <- "This Script is to plot pearson correlation heatmap based on deeptools multiBigwigSummary matrix, which grouped by specified groups"
  
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
  input <- "top100.tab"
  group <- "sample.group"
  output_dir <- "./results"
  colname <- "sample.name"
  width <- 14
  height <- 12
  fontsize_row <- 20
  fontsize_number <- 13
  upper <- 1
  lower <- -1
  display_numbers <- T
}

# create dir
if (T) {
  dir.create(paste0(output_dir, "/tab"), showWarnings = F, recursive = T)
  dir.create(paste0(output_dir, "/pic"), showWarnings = F, recursive = T)
}

# correlation matrix
if (T) {
  output_rds <- paste0(output_dir, "/paired_cor.rds")
  if (file.exists(output_rds)) {
    results <- readRDS(output_rds)
  }
  if (!file.exists(output_rds)) {
    # load the data
    if (T) {
      dat <- data.table::fread(input, header = T, sep = "\t", quote="\'", data.table = F)
      dat <- dat[,-c(1:3)]
    }
    
    # load the group
    if (T) {
      group <- read.table(group, header = F, sep = "\t", fill = T, comment.char = "")[,1]
    }
    
    # change the colnames of data
    if (exists("colname")) {
      name <- read.table(colname, header = F, sep = "\t", fill = T, comment.char = "")[,1]
      colnames(dat) <- name
    }
    
    # multicore to calculate the correlation after remove 0
    if (T) {
      # set the parallel environment
      if (T) {
        # get all cores number in machine
        cl.cores <- detectCores()
        
        # log file
        file <- paste0(output_dir, "/multi_c.log")
        
        # remove old log file
        if (file.exists(file)) {
          file.remove(file)
        }
        
        # set 65% cores to calculate
        # cl <- makeCluster(round(cl.cores * 0.5), outfile = file)
        cl <- makeCluster(20, outfile = file)
        
        # get all variable in base environment
        clusterExport(cl, "dat", envir = environment())
      }
      
      # prepare for parallel calculation
      if (T) {
        groups <- unique(group)
      }
      
      # calculate parallelly
      if (T) {
        results <- parLapply(cl, groups, function(x) {
          # x <- groups[1]
          
          # subset the data
          sub_dat <- dat[,grepl(x, colnames(dat), ignore.case = T)]
          
          if (is.vector(sub_dat)) {
            cor_dat=0
          }
          if (is.data.frame(sub_dat)) {
            sub_dat <- sub_dat[apply(sub_dat, 1, sum)!=0, ]
			sub_dat <- na.omit(sub_dat)
            cor_dat <- cor(sub_dat)
          }
          return(cor_dat)
        })
        stopCluster(cl)
      }
      
      # set name for results
      names(results) <- groups
      
      # save the results
      saveRDS(results, file = output_rds)
    }
  }
}

# output the table and picture
if (T) {
  for (x in names(results)) {
    # x <- "293t_H2AK5ac"
    
    # get the data
    cor_dat <- results[[x]]
    
    # output the correlation matrix
    if (T) {
      file <- paste(output_dir, "/tab/", x, ".paired_cor_rm0.mat", sep = "")
      write.table(cor_dat, file = file, row.names = T,col.names = T,sep = "\t",quote = F)
    }
    
    # output the correlation pheatmap
    if (T) {
      file <- paste(output_dir, "/pic/", x, ".paired_cor_rm0.png", sep = "")
      if (is.matrix(cor_dat)) {
        pheatmap::pheatmap(cor_dat,scale="none",
                           show_colnames=F, show_rownames=T,
                           breaks=seq(lower, upper, length.out=100),
                           cluster_cols=T, cluster_rows=T,
                           border_color="black", colorRampPalette(c("blue","white","red"))(100),
                           fontsize_row=fontsize_row, fontsize_number=fontsize_number,
                           filename=file, width=width, height=height,
                           display_numbers=display_numbers)  
      }
      if (is.vector(cor_dat)) {
        png(file)
        plot(x=1,y=1)
        title(main = "Only one sample")
        dev.off()
      }
    }
  }
}


