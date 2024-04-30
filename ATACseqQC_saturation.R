# load the library
if (T) {
  rm(list = ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(stringr)
  suppressPackageStartupMessages(library(ATACseqQC))
}

# Get parameters
if (T) {
  args = commandArgs(trailingOnly=TRUE)
  bamfile = args[1]
  labels = args[2]
  output_dir = args[3]
  type = args[4]
}

# test the results
if (T) {
  subsamplingPeakFiles <- list.files(output_dir, full.names = T, recursive = T, pattern = ".*")
  if (sum(grepl("narrowPeak",subsamplingPeakFiles))==0) {
    stop("No accessible reads!")
  }
}


# Fragment size distribution
if (type == "PE") {
  png(paste0(output_dir,"/",labels,"_fragSizeDist.png"))
  fragSizeDist(bamfile, labels)
  dev.off()
}

# define the function of saturationPlot
if (T) {
  saturationPlot <- function (subsamplingPeakFiles, subsamplingSizes, fdr = 0.05, fdrCol = 9, startCol = 2, endCol = 3, outPrefix) {
    if (is.null(names(subsamplingSizes)) || !identical(subsamplingPeakFiles, names(subsamplingSizes))) {
      stop("Subsampling peak file names should match the name of subsamplingSize!")
    }
    
    # read all peaks file
    if (T) {
      peaks <- lapply(subsamplingPeakFiles, function(x) {
        readr::read_table(file = x, col_names = FALSE, comment = "#")
      })
      
      names(peaks) <- subsamplingPeakFiles  
    }
    
    # peaks number
    if (T) {
      numPeaks <- sapply(peaks, function(x) {
        n_row <- nrow(x)
        ifelse(n_row==0,
               0,
               sum(10^(-x[,fdrCol]) <= fdr))
      })
      names(numPeaks) <- names(peaks)  
    }
    
    # peaks breadth
    if (T) {
      breadth <- sapply(peaks, function(x) {
        n_row <- nrow(x)
        ifelse(n_row==0,
               0,
               sum(x[endCol] - x[startCol] + 1))
      })
      names(breadth) <- names(peaks)  
    }
    
    # summary
    if (T) {
      peakStat <- data.frame(subsamplingSizes = subsamplingSizes, 
                             numPeaks = numPeaks, 
                             breadth = breadth)
      
      # transfer to MB
      subsamplingSizes <- peakStat$subsamplingSizes/10^6
      breadth <- peakStat$breadth/10^6
      # transfer to k number
      numPeaks <- peakStat$numPeaks/10^3
    }
    
    # peak_number-based_saturation plot
    if (T) {
      pdf(paste0(outPrefix, "_peak_number-based_saturation_plot.pdf"), width = 5, height = 5)
      
      plot(x = subsamplingSizes, 
           y = numPeaks, 
           pch = 16, 
           xlab = expression(Effective ~ fragments ~ x ~ 10^6), 
           ylab = expression(Peaks ~ x ~ 10^3))
      lines(loess.smooth(x = subsamplingSizes, y = numPeaks, span = 2, 
                         degree = 2, family = "gaussian", evaluation = 50))
      dev.off()
    }
    
    # peak_breadth-based_saturation plot
    if (T) {
      pdf(paste0(outPrefix, "_peak_breadth-based_saturation_plot.pdf"), width = 5, height = 5)
      
      plot(x = subsamplingSizes, 
           y = breadth, 
           pch = 16, 
           xlab = expression(Effective ~ fragments ~ x ~ 10^6), 
           ylab = expression(Total ~ peak ~ breadth ~ (Mb)))
      lines(loess.smooth(x = subsamplingSizes, y = breadth, span = 2, 
                         degree = 2, family = "gaussian", evaluation = 50))
      dev.off()
    }
  }  
}

# saturationPlot
if (T) {
  subsamplingPeakFiles <- list.files(output_dir, full.names = T, recursive = T, pattern = ".*narrowPeak$")
  subsamplingSizes <- str_extract(subsamplingPeakFiles,"reads_[0-9]*_peaks.narrowPeak")
  subsamplingSizes <- str_extract(subsamplingSizes,"[0-9]+")
  subsamplingSizes <- as.numeric(subsamplingSizes)
  names(subsamplingSizes) <- subsamplingPeakFiles
  
  saturationPlot(subsamplingPeakFiles, subsamplingSizes, 
                 outPrefix = paste0(output_dir,"/",labels))
}

