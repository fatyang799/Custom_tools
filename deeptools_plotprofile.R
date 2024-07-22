# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(stringr)
  library(reshape2)
  library(ggplot2)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "A file recording input files list [default %default]"),
    
    make_option(c("-g", "--group"), type = "character", default = NULL, action = "store",
                help = "A file recording the type of input files, e.g. ATAC, RNA, et al. It represent x group [default %default]"),
    
    make_option(c("-G", "--group2"), type = "character", default = NULL, action = "store",
                help = "Additional file recording the type of input files. It represent y group. When this is set, ggplot2 facet the picture by group~group2 [default %default]"),
    
    make_option(c("-n", "--ncol"), type = "numeric", default = 4, action = "store",
                help = "When the plot are faceted, the number of column in the ggplot figure [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "TSS_freeY.png", action = "store",
                help = "The output file name [default %default]"),
    
    make_option(c("-t", "--TSS"), type = "logical", default = FALSE, action = "store_true",
                help = "If set this, then the file is for TSS. Default is FALSE, which means Gene body [default \"%default\"]"),
    
    make_option(c("-f", "--free"), type = "logical", default = FALSE, action = "store_true",
                help = "If set this, then free y axis while facet. Default is FALSE [default \"%default\"]"),
    
    make_option(c("-w", "--width"), type = "numeric", default = 14, action = "store",
                help = "The output figure width size [default %default]"),
    
    make_option(c("-H", "--height"), type = "numeric", default = 9, action = "store",
                help = "The output figure height size [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript deeptools_plotprofile.R -i file.txt -t -f -o TSS_freeY.png -g group1.txt\nRscript deeptools_plotprofile.R -i file.txt -o Body_fixedY.png -g group1.txt -G group2.txt"
  description_message <- "This Script is to plot profile picture by ggplot to replace deeptools default output."
  
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
  TSS <- T
  input <- "file1.txt"
  free <- T
  group <- "group1.txt"
  group2 <- NA
  ncol <- 4
}

# get all files
if (T) {
  # matrix data
  if (T) {
    files <- read.table(input,header = F,comment.char = "")[,1]
    dat <- lapply(files, function(x){
      read.table(x,header = F,sep = "\t")
    })
  }
  
  # group data
  if (T) {
    if (exists("group")) {
      group <- read.table(group, header = F, sep = "\t")[,1]
    }
    if (exists("group2")) {
      group2 <- read.table(group2, header = F, sep = "\t")[,1]
    }
  }
}

# merge files in a data frame
if (T) {
  # merge raw data
  if (T) {
    data <- do.call(rbind, dat)
  }
  
  # get label, bin, and dat
  if (T) {
    label <- data[seq(1,nrow(data),3),]
    bin <- data[seq(2,nrow(data),3),]
    dat <- data[seq(3,nrow(data),3),]
  }
  
  # modify the dat
  if (T) {
    rownames(dat) <- dat[,1]
  }
  
  # check the bin and label and determine the colname of dat
  if (T) {
    same_bin <- all(sapply(bin, function(x) {length(unique(x))==1}))
    same_label <- all(sapply(label, function(x) {length(unique(x))==1}))
    
    if (same_bin & same_label) {
      colnames(dat) <- str_split(bin[1,],"[.]",simplify = T)[,1]
    }
  }
  
  # add additional attribution
  if (T) {
    if (exists("group")) {
      dat$Marker <- group
    }
    
    if (exists("group2")) {
      dat$group2 <- group2
    }
  }
}

# ggplot2
if (T) {
  # ggdat preparation
  if (T) {
    n_col <- c(1:2, which(grepl("Marker|group2", colnames(dat))))
    ggdat <- melt(dat, id.vars= colnames(dat)[n_col], variable.name = "Bin", value.name = "Value")
    colnames(ggdat)[1] <- "File"
  }
  
  # management the ggdat
  if (T) {
    ggdat$Value <- as.numeric(ggdat$Value)
    
    value1 <- which(grepl("[0-9]\\.?[0-9]?Kb",label[1,]))
    value2 <- which(grepl("TSS|TES",label[1,]))
    if (TSS) {
      value2 <- which(grepl("tick",label[1,]))
    }
    value <- c(value1,value2)-2
    names(value) <- label[1,][c(value1,value2)]
    if (TSS) {
      names(value)[3] <- "TSS"
    }
  }
  
  # ggplot picture
  if (T) {
    colnames(ggdat)
    p <- ggplot(data = ggdat) +
      geom_line(aes(x=Bin, y=Value, group = File, colour = File), linewidth=0.8) +
      scale_x_discrete(name = "",
                       breaks = value,
                       labels = names(value)) +
      # level from 0
      scale_y_continuous(name = NULL,
                         limits = c(0,NA)) +
      ylab(label = NULL)+
      theme(legend.position = "none",
            axis.title = element_text(size = rel(1.2), face="bold"),
            axis.text = element_text(size = rel(1.2), face="bold"),
            strip.text = element_text(size = rel(1.2), face="bold"))
    
    if (exists("group2")) {
      if (! exists("group")) {
        if (free) {
          p1 <- p + facet_wrap(~group2, ncol = ncol,scales = "free")
#          p1 <- p + ggh4x::facet_wrap2(~group2, ncol = ncol,scales = "free", independent = "all")
        }
        if (!free) {
          p1 <- p + facet_wrap(~group2, ncol = ncol,scales = "fixed")
        }
      }
      if (exists("group")) {
        if (free) {
#          p1 <- p + facet_grid(Marker~group2, scales = "free")
          p1 <- p + ggh4x::facet_grid2(Marker~group2, scales = "free", independent = "all")
        }
        if (!free) {
          p1 <- p + facet_grid(Marker~group2, scales = "fixed")
        }
      }
    }
    
    if (! exists("group2")) {
      if (! exists("group")) {
        p1 <- p
      }
      if (exists("group")) {
        if (free) {
          p1 <- p + facet_wrap(~Marker, ncol = ncol,scales = "free")
#          p1 <- p + ggh4x::facet_wrap2(~Marker, ncol = ncol,scales = "free", independent = "all")
        }
        if (!free) {
          p1 <- p + facet_wrap(~Marker, ncol = ncol,scales = "fixed")
        }
      }
    }
  }
  
  # save picture
  ggsave(plot = p1, filename = output, width = width, height = height)
}


