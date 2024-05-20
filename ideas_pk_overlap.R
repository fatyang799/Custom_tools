# load the environment
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  library(optparse)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "The input file, which record the full path of all bin location ID files [default %default]"),
    
    make_option(c("-o", "--outfig"), type = "character", default = "heatmap.png", action = "store",
                help = "The output heatmap filename [default %default]"),
    
    make_option(c("-O", "--outmat"), type = "character", default = "overlap.rds", action = "store",
                help = "The overlap statistics filename, the format of which is **rds** [default %default]"),
    
    make_option(c("-l", "--label"), type = "character", default = "file_name.txt", action = "store",
                help = "The file which record the alias label for files record in -i file.txt [default %default]"),
    
    make_option(c("-s", "--scale_percent"), type = "character", default = "row", action = "store",
                help = "The percentage reference, which can be row or col [default %default]"),
    
    make_option(c("-w", "--width"), type = "numeric", default = 12, action = "store",
                help = "The output figure width size [default %default]"),
    
    make_option(c("-H", "--height"), type = "numeric", default = 8, action = "store",
                help = "The output figure height size [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_pk_overlap.R -i 1.file.txt -l 1.file_group.txt -o heatmap.png -O overlap.rds -s row"
  description_message <- "This Script is to calculate the pk overlap across multiple bigwig files The peak definition: FDR(P(zscale sig)) < 0.05"
  
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
  input <- "1.file.txt"
  label <- "1.file_group.txt"
  output <- "heatmap.png"
  width = 12
  height = 8
}

# get all library
if (T) {
  library(reshape2)
  suppressPackageStartupMessages(library(ComplexHeatmap))
}

# get all files
if (T) {
  files <- read.table(input, header = F, sep = "\t", fill = T, comment.char = "")[, 1]
  labels <- read.table(label, header = F, sep = "\t", fill = T, comment.char = "")[, 1]
  if (length(labels) != length(unique(labels))) {
    print(paste0("There are duplicated label in ", label, ", please check."))
    stop(paste0("There are duplicated label in ", label))
  }
}

# get all content
if (T) {
  dat <- lapply(files, function(x) {
    data.table::fread(x, header = F, data.table = F)[, 1]
  })
  names(dat) <- labels
}

# loop to calculation
if (T) {
  stat <- lapply(labels, function(id1) {
    id1_len <- length(dat[[id1]])
    lapply(labels, function(id2) {
      over_len <- length(intersect(dat[[id1]], dat[[id2]]))
      c(id1, id2, over_len, id1_len)
    })
  })
}

# format
if (T) {
  # merge the results
  if (T) {
    dat <- lapply(stat, function(x) {
      do.call(rbind, x)
    })
    
    dat <- do.call(rbind, dat)
  }
  
  # change the labels
  if (T) {
    dat <- as.data.frame(dat)
    colnames(dat) <- c("id1", "id2", "over_len", "id1_len")
  }
  
  # save dat
  if (T) {
    saveRDS(dat, file = outmat)
  }
  
  # long2wide
  if (T) {
    ggdat <- dcast(dat, id1~id2, value.var = "over_len")
    rownames(ggdat) <- ggdat[, 1]
    ggdat <- ggdat[, -1]
  }
  
  # file pk number
  if (T) {
    len <- dat[, c(1,4)]
    len <- len[!duplicated(len$id1), ]
    rownames(len) <- len[, 1]
    len <- len[match(rownames(ggdat), len$id1), ]
  }
  
  # transfer to percentage
  if (T) {
    # row percentage
    if (scale_percent == "row") {
      row_ggdat <- cbind(ggdat, len$id1_len)
      
      row_ggdat <- t(apply(row_ggdat, 1, function(x) {
        as.numeric(x[-length(x)])/as.numeric(x[length(x)])
      }))
      row_ggdat <- data.frame(row_ggdat)
      colnames(row_ggdat) <- rownames(row_ggdat)
      
      dat <- row_ggdat
    }
    
    # column percentage
    if (scale_percent == "column") {
      col_ggdat <- rbind(ggdat, len$id1_len)
      
      col_ggdat <- sapply(col_ggdat, function(x) {
        as.numeric(x[-length(x)])/as.numeric(x[length(x)])
      })
      col_ggdat <- data.frame(col_ggdat)
      rownames(col_ggdat) <- colnames(col_ggdat)
      
      dat <- col_ggdat
    }
  }
}

# pheatmap
if (T) {
  # color setting
  if (T) {
    min <- floor(min(dat)*10)/10
    max <- 1
    
    col_fun = circlize::colorRamp2(c(min, max), c("white", "red"))
  }
  
  # reference title
  if (T) {
    row_title <- ifelse(scale_percent == "row", "Percentage Reference", NA)
    column_title <- ifelse(scale_percent == "row", NA, "Percentage Reference")  
  }
  
  # annotation
  if (T) {
    len$id1_len <- as.numeric(len$id1_len)
    if (all(len$id1 != rownames(dat))) {
      stop("The order of len is not same as the order of dat")
    }
  }
  
  # plot heatmap
  if (T) {
    if (scale_percent == "row") {
      p <- Heatmap(as.matrix(dat), name = "Percentage", col = col_fun,
                   rect_gp = gpar(col = "black"), 
                   border = TRUE, row_title = row_title, column_title = column_title, 
                   row_title_side = "left", column_title_side = "top",
                   row_names_side = "right", column_names_side = "bottom", column_names_rot = 45, 
                   cluster_rows = FALSE, cluster_columns = FALSE, 
                   right_annotation = rowAnnotation(pk_num = anno_barplot(len$id1_len)))
    }
    
    if (scale_percent == "column") {
      p <- Heatmap(as.matrix(dat), name = "Percentage", col = col_fun,
                   rect_gp = gpar(col = "black"), 
                   border = TRUE, row_title = row_title, column_title = column_title, 
                   row_title_side = "left", column_title_side = "top",
                   row_names_side = "right", column_names_side = "bottom", column_names_rot = 45, 
                   cluster_rows = FALSE, cluster_columns = FALSE, 
                   top_annotation = columnAnnotation(PK_num = anno_barplot(len$id1_len)))
    }  
  }
  
  # save plot
  if (T) {
	# prevent gerenate Rplots.pdf
    pdf(NULL)
    plot <- ggplotify::as.ggplot(grid.grabExpr(draw(p)))
    ggplot2::ggsave(filename = outfig, plot = plot, height = height, width = width)
  }
}

