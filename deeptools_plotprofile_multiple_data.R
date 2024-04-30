

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
    make_option(c("-i", "--input"), type = "character", default = "Merged_TargetRegion_profile_tss.mat", action = "store",
                help = "Output file of deeptools plotProfile, which include multiple samples data [default %default]"),
    
    make_option(c("-g", "--group1"), type = "character", default = NULL, action = "store",
                help = "A group type for input files. It can be a cell type or a marker type. [default %default]"),
    
    make_option(c("-G", "--group2"), type = "character", default = NULL, action = "store",
                help = "A group type for input files. It can be a cell type or a marker type. If set this, then the output ggplot2 figure will be faceted by \"facet_grid(group2~group1)\" [default %default]"),
    
    make_option(c("-a", "--afterRegionStartLength"), type = "double", default = 2000, action = "store",
                help = "The downstream lenght of genes, which should be same as setting in computeMatrix [default %default]"),
    
    make_option(c("-b", "--beforeRegionStartLength"), type = "double", default = 2000, action = "store",
                help = "The upstream lenght of genes, which should be same as setting in computeMatrix [default %default]"),
    
    make_option(c("-m", "--regionBodyLength"), type = "double", default = 5000, action = "store",
                help = "The lenght of gene body, which should be same as setting in computeMatrix. Only when dealing with file for gene body you have to set this parameter [default %default]"),
    
    make_option(c("-B", "--binSize"), type = "double", default = 200, action = "store",
                help = "The bin size, which should be same as setting in computeMatrix [default %default]"),
    
    make_option(c("-A", "--Body"), type = "logical", default = FALSE, action = "store_true",
                help = "If set this, then the file is for Gene body. Default is FALSE, which means file is for TSS [default %default]"),
    
    make_option(c("-f", "--free"), type = "logical", default = FALSE, action = "store_true",
                help = "If set this, then free x and y axis while facet. Default is FALSE [default %default]"),
    
    make_option(c("-n", "--nrow"), type = "double", default = 4, action = "store",
                help = "Determing how many rows to facet the figure, which will be applied to \"facet_wrap(nrow=nrow)\" [default %default]"),
    
    make_option(c("-o", "--output"), type = "character", default = "plotProfile_manual.pdf", action = "store",
                help = "Output Figure file [default %default]"),
    
    make_option(c("-w", "--width"), type = "double", default = 14, action = "store",
                help = "Plot width size of figure [default %default]"),
    
    make_option(c("-H", "--height"), type = "double", default = 9, action = "store",
                help = "Plot height size of figure [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript deeptools_plotprofile_multiple_data.R -i Merged_TargetRegion_profile_tss.mat -g cell.txt -G marker.txt -a 3000 -b 3000 -B 50 -f -n 4 -o plotProfile_TSS_m.pdf"
  description_message <- "This Script is to plot profile picture by ggplot to replace deeptools default output. ***For Situation: there are various samples in one picture.***"
  
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
  input <- "2.profile_dat/1.TSS/1.multi_rep_point_tss.profile.mat"
  Body <- F
  group1 <- "cell.txt"
  group2 <- "marker.txt"
  afterRegionStartLength <- 2000
  beforeRegionStartLength <- 2000
  regionBodyLength <- 5000
  binSize <- 200
  free <- T
  nrow <- 4
  output <- "plotProfile_manual.pdf"
  width <- 14
  height <- 40
}

# get group test info
if (T) {
  test1 <- is.null(group1)
  test2 <- is.null(group2)
  test <- sum(c(test1, test2))
}

# get all files
if (T) {
  if (!test1) {
    group1 <- read.table(group1, header = F, sep = "\t")[,1]  
  }
  if (!test2) {
    group2 <- read.table(group2, header = F, sep = "\t")[,1]  
  }
  
  input <- read.table(input, header = F, sep = "\t", fill = T)
}

# format the data
if (T) {
  # bin number
  if (T) {
    n_bin <- (afterRegionStartLength + beforeRegionStartLength) / binSize
    if (Body) {
      n_bin <- n_bin + (regionBodyLength / binSize)
    }
  }
  
  # group data check
  if (T) {
    if (test==2) {
      stop("No group info")
    }
    if (test==1) {
      n_sample <- ifelse(test1, length(group2), length(group1))
    }
    if (test==0) {
      if (length(group1) != length(group2)) {
        stop("The number of group info is not identical")
      }
      n_sample <- nrow(group1)
    }
  }
  
  # modify the colnames of input data
  if (T) {
    # remove redundent column
    input <- input[ ,1:(2+n_bin)]
    
    # colnames
    if (T) {
      colr1 <- c(as.matrix(input[1,]))
      colr2 <- c(as.matrix(input[2,]))
      colr2 <- str_split(colr2,"[.]",simplify = T)[,1]
      coln <- ifelse(is.na(colr1),
                     paste0("Bin",colr2),
                     colr1)
      coln[1:2] <- c("Sample_Label", "Region_Label")
      if (!Body) {
        coln[coln == "tick"] <- "TSS"
      }
      colnames(input) <- coln
      
      input <- input[-(1:2),]
    }
  }
  
  # add sample type attribution
  if (T) {
    if (!test1) {
      input$group1 <- group1
    }
    
    if (!test2) {
      input$group2 <- group2
    }
  }
  
  # ggdat preparation
  if (T) {
    coln <- colnames(input)
    group_n <- which(grepl("group",coln))
    
    ggdat <- melt(input, id.vars= coln[c(1:2,group_n)], variable.name = "Bin", value.name = "Value")
    ggdat$Value <- as.numeric(ggdat$Value)
  }
}

# ggplot2
if (T) {
  # factor the group
  if (T) {
    if (!test1) {
      ggdat$group1 <- factor(ggdat$group1, levels = sort(unique(ggdat$group1)))  
    }
    if (!test2) {
      ggdat$group2 <- factor(ggdat$group2, levels = sort(unique(ggdat$group2)))
    }
  }
  
  # basic ggplot
  if (T) {
    # get uniq id
    xlabs <- unique(ggdat$Bin)
    
    p <- ggplot(data = ggdat) + 
      geom_line(aes(x=Bin, y=Value, group = Sample_Label, colour = Sample_Label), linewidth=0.9) + 
      scale_x_discrete(name = "",
                       breaks = xlabs[!grepl("Bin",xlabs)]) +
      ylab(label = "Signal Strength")+
      theme(legend.position = "none",
            strip.text  = element_text(size = 10, face="bold"),
            axis.text.x = element_text(size=10, face="bold"),
            axis.text.y = element_text(size=10))
  }
  
  if (!test1) {
    if (free) {
      p1 <- p + facet_wrap(~group1, scales = "free", nrow = nrow)
    }
    if (!free) {
      p1 <- p + facet_wrap(~group1, scales = "fixed", nrow = nrow)
    }
  }
  
  if (!test2) {
    if (free) {
      p1 <- p + facet_wrap(~group2, scales = "free", nrow = nrow)
    }
    if (!free) {
      p1 <- p + facet_wrap(~group2, scales = "fixed", nrow = nrow)
    }
  }
  
  if (!test1 & !test2) {
    if (free) {
      p1 <- p + facet_grid(group2~group1, scales = "free")
    }
    if (!free) {
      p1 <- p + facet_grid(group2~group1, scales = "fixed")
    }
  }
  
  # save picture
  ggsave(plot = p1, filename = output, width = width, height = height)
}


