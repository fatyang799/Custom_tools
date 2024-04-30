

# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
  library(reshape2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = "file.txt", action = "store",
                help = "The input file. It records files which record the ARI value between state after removing a marker and state with all markers [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_overall_tendency.R"
  description_message <- "This Script is to plot overall tendency for IDEAS results"
  
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

# Test data
if (F) {
  input <- "file.txt"
}

# get all files
if (T) {
  files <- read.table(input, header = F)[,1]
}

# get all data
if (T) {
  dat <- lapply(files, function(x){
    number <- str_extract(x,"no[0-9]{1,2}")
    file <- read.table(x,header = T,sep = "\t")
    file <- file[order(file$Mean_ARI),]
    rownames(file) <- 1:nrow(file)
    marker <- file$Marker
    order <- as.numeric(rev(rownames(file)))
    total <- nrow(file)
    order_percent <- order/total
    removed_M <- tail(marker,1)
    ARI <- file$Mean_ARI
    result <- data.frame(
      number=number,
      marker=marker,
      order=order,
      total=total,
      order_percent=order_percent,
      removed_M=removed_M,
      ARI=ARI
    )
    result
  })
  results <- do.call(rbind,dat)
}

# prepare for plotting
if (T) {
  results <- results[order(results$total,results$order,decreasing = c(T,F)),]
  # save data
  write.table(results,file = "raw_plot_data.txt", quote = F, sep = "\t", col.names = T, row.names = F)
  
  allmarker <- unique(results$marker)
  allmarker_n <- length(allmarker)
  removed_marker <- results[results$order==1,"marker"]
  removed_marker_n <- length(removed_marker)
}

# percent_order_plot
if (T) {
  # data prepare
  if (T) {
    ggdat <- data.frame(marker=allmarker)
    
    for (i in 1:removed_marker_n) {
      # i <- 1
      total_M_number <- allmarker_n + 1 - i
      data <- results[results$total==total_M_number,]
      
      # have been removed marker
      removed_M <- unique(data$removed_M)
      
      # all marker order
      M_order <- data$order_percent
      names(M_order) <- data$marker
      
      # sort the marker
      M_order <- M_order[match(ggdat$marker,names(M_order))]
      M_order[is.na(M_order)] <- 0
      
      # integrate the data
      ggdat[,paste0("M",total_M_number)] <- M_order
    }
    
    # prepare for label
    if (T) {
      label_dat <- ggdat[,1:2]
      label_dat[,2] <- label_dat[,2]*100
      label_dat$x <- colnames(ggdat)[2]
    }
    
    ggdat <- suppressMessages(melt(ggdat))
    ggdat$value <- ggdat$value*100
  }
  
  # ggplot
  if (T) {
    # basic plot
    if (T) {
      p <- ggplot(data=ggdat,aes(x=variable,y=value,colour=marker,group = marker))+
        geom_line(size=1)+
        geom_point(size=2)+
        xlab("")+
        ylab("Order_for_Importance")+
        theme_bw()+
        theme(axis.text.x = element_text(size = rel(1.1)),
              axis.text.y = element_text(size = rel(1.1)),
              strip.text  = element_text(size = rel(1.1)),
              legend.position="none")  
    }
    
    # facet
    if (T) {
      p+facet_wrap(~marker,ncol=4)
      # save plot
      ggsave(filename="percent_order_plot_facet.png", height=10, width=20)
    }
    
    # all marker tendency
    if (T) {
      p + geom_text(data=label_dat,aes(x=label_dat[,3], y=label_dat[,2]),label=label_dat$marker, nudge_x=-0.2, size=5)
      # save plot
      ggsave(filename="percent_order_plot_overall.png", height=10, width=20)
    }
  }
}

# each_marker_ARI_plot
if (T) {
  # merge plot
  if (T) {
    # label
    if (T) {
      ari=results[results$total==max(results$total), "ARI"]
      
      label_dat <- data.frame(number="Markers",
                              marker=allmarker,
                              order=NA,
                              total=NA,
                              order_percent=NA,
                              removed_M=NA,
                              ARI=seq(max(ari),min(ari),length.out=allmarker_n))
    }
    
    # merge data
    if (T) {
      ggdat <- rbind(label_dat,results)
      ggdat <- melt(ggdat,id.vars = c("number","marker"),measure.vars = "ARI")
      n <- na.omit(as.numeric(gsub("no","",ggdat$number)))
    }
    
    # sort
    if (T) {
      ggdat$number <- factor(ggdat$number,levels = c("Markers",paste0("no", sort(unique(n),decreasing = T))))
    }
    
    # ggplot2
    if (T) {
      ggplot(data=ggdat,aes(x=number,y=value,colour=marker,group = marker))+
        geom_line(size=1)+
        geom_point(size=2)+
        xlab("")+
        ylab("ARI")+
        geom_text(data=label_dat,aes(x=number,y=ARI),label=label_dat$marker,nudge_x=-0.3,size=5)+
        theme_bw()+
        theme(axis.text.x = element_text(size = rel(1.1)),
              axis.text.y = element_text(size = rel(1.1)),
              strip.text  = element_text(size = rel(1.1)),
              legend.position="none")
      
      # save plot
      ggsave(filename="each_marker_ARI_plot_overall.png", height=10, width=20)
    }
  }
  
  # facet
  if (T) {
    # prepare for ggdat
    if (T) {
      ggdat <- melt(results,id.vars = c("number","marker"), measure.vars = "ARI")
      n <- as.numeric(unique(gsub("no","",ggdat$number)))
    }
    
    # sort
    if (T) {
      ggdat$number <- factor(ggdat$number,levels = paste0("no", sort(n,decreasing = T)))
    }
    
    # ggplot2
    if (T) {
      ggplot(data=ggdat)+
        geom_line(aes(x=number, y=value, colour=marker, group = marker), size=1)+
        geom_point(aes(x=number, y=value, colour=marker, group = marker), size=2)+
        xlab("")+
        ylab("ARI")+
        facet_wrap(~marker,ncol=4)+
        theme_bw()+
        theme(axis.text.x = element_text(size = rel(1.1), angle = 45, hjust=1, vjust=1),
              axis.text.y = element_text(size = rel(1.1)),
              strip.text  = element_text(size = rel(1.1)),
              legend.position="none")
      
      # save plot
      ggsave(filename="each_marker_ARI_plot_facet.png", height=10, width=20)
    }
  }
}

# overall_tendency_plot
if (T) {
  # prepare for data
  if (T) {
    ggdat <- results[results$order==1,]
    ggdat <- ggdat[order(ggdat$total,decreasing = T),]
    ggdat$x <- paste0(ggdat$number,"\n",ggdat$marker)
    ggdat$x <- factor(ggdat$x,levels = ggdat$x)
  }
  
  # ggplot
  if (T) {
    ggplot(data=ggdat,aes(x=x,y=ARI,group=1))+
      geom_line(size=0.8)+
      geom_point(size=2)+
      xlab("")+
      ylab("ARI value")+
      #scale_y_continuous(limits = c(0.5, 1))+
      theme_bw()+
      theme(axis.text.x = element_text(size = rel(1.1)),
            axis.text.y = element_text(size = rel(1.1)))
    ggsave("Overall_tendency.png", height = 10, width = 15)
  }
}

