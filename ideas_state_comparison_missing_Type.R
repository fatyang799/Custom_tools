# Load environment
if (T) {
  rm(list=ls())
  options(stringAsFactors = F)
  options(warn =-1)
  library(optparse)
  library(stringr)
  library(ggplot2)
}

# Set parameters
if (T) {
  option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL, action = "store",
                help = "The statistics file produced by bash `uniq -c` [default %default]"),
    
    make_option(c("-s", "--source_top5_percent_file"), type = "character", default = "source_top5_percent_file.xls", action = "store",
                help = "A compared state file [default %default]"),
    
    make_option(c("-t", "--target_top5_percent_file"), type = "character", default = "target_top5_percent_file.xls", action = "store",
                help = "Which column of file record the value in reference file [default %default]"),
    
    make_option(c("-T", "--state_type_file"), type = "character", default = "state_type_file.xls", action = "store",
                help = "Which column of file record the value in compared file [default %default]"),
    
    make_option(c("-n", "--note"), type = "character", default = "Readme_note.txt", action = "store",
                help = "A readme file to tell reader the meaning of colname for output file [default %default]")
  )
}

# Analysis parameters
if (T) {
  usage_message <- "Rscript ideas_state_comparison_missing_Type.R -i 1.H1_ref1_compared.no2.stat -s source_top5_percent_file.xls -t target_top5_percent_file.xls -T state_type_file.xls -n Readme_note.txt"
  description_message <- "This Script is to statistics 8 type of states, which include A, B, C, D, E, F, G and H. Among them, the A and C are existing, and the others are missing."
  
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
  input <- "data/1.raw/1.statistics/remove_1M/1.H1_rm_H4K91ac.stat"
  note <- "test.note"
  source_top5_percent_file <- "source_top5_percent_file.xls"
  target_top5_percent_file <- "target_top5_percent_file.xls"
  state_type_file <- "state_type_file.xls"
}

# read the statistics results
if (T) {
  dat <- read.table(file = input, header = T, sep = "\t", fill = T)
  dat$source <- paste0("S_", str_split(dat[,2], "_", simplify = T)[,1])
  dat$target <- paste0("T_", str_split(dat[,2], "_", simplify = T)[,2])
}

# source
if (T) {
  # statistics for source
  if (T) {
    # total bin number
    if (T) {
      source <- tapply(dat$Number, dat$source, sum)
      source <- data.frame(state = names(source),
                           total_n = source)
      
      target <- tapply(dat$Number, dat$target, sum)
      target <- data.frame(state = names(target),
                           total_n = target)
      
      sum(source$total_n)
      sum(target$total_n)
    }
    
    # source and target state number
    if (T) {
      tab <- table(dat$source)
      summary(as.numeric(tab))
      
      tab <- table(dat$target)
      summary(as.numeric(tab))
      
      rm(tab)
    }
    
    # top5 percentage statistics
    if (T) {
      source_top5_percent <- data.frame(state = source$state)
      rownames(source_top5_percent) <- source_top5_percent$state
      
      for (s in unique(dat$source)) {
        # s <- "S_34"
        sub_dat <- dat[dat$source == s, ]
        
        sub_dat <- sub_dat[order(sub_dat$Number, decreasing = T), ]
        total <- source[source$state==s, 2]
        
        # top1-5占该state的比例
        source_top5_percent[s, "top1_p"] <- sub_dat$Number[1]/total
        source_top5_percent[s, "top2_p"] <- sub_dat$Number[2]/total
        source_top5_percent[s, "top3_p"] <- sub_dat$Number[3]/total
        source_top5_percent[s, "top4_p"] <- sub_dat$Number[4]/total
        source_top5_percent[s, "top5_p"] <- sub_dat$Number[5]/total
        
        # top1与top2-5之间的fold change
        source_top5_percent[s, "top2_fc"] <- sub_dat$Number[1]/sub_dat$Number[2]
        source_top5_percent[s, "top3_fc"] <- sub_dat$Number[1]/sub_dat$Number[3]
        
        # top1-2对应在target中的state
        source_top5_percent[s, "top1_target"] <- sub_dat$target[1]
        source_top5_percent[s, "top2_target"] <- sub_dat$target[2]
        
        # source中该state总共有多少
        source_top5_percent[s, "source_total"] <- total
      }
    }
    
    # top2-5 cumsum percentage statistics
    if (T) {
      source_top5_percent$sum_source_top1_2 <- apply(source_top5_percent[,2:3], 1, sum)
      source_top5_percent$sum_source_top1_3 <- apply(source_top5_percent[,2:4], 1, sum)
      source_top5_percent$sum_source_top1_4 <- apply(source_top5_percent[,2:5], 1, sum)
      source_top5_percent$sum_source_top1_5 <- apply(source_top5_percent[,2:6], 1, sum)
    }
    
    # add additional stata attribution
    if (T) {
      source_top5_percent$percentage <- source_top5_percent$source_total / sum(source$total_n)
    }
  }
  
  # 【source_sep_Y】 filter by source: top1/top2<=2
  # 【source_sep_N】 filter by source: top1/top2>2
  if (T) {
    source_sep_Y <- source_top5_percent[source_top5_percent$top2_fc <= 2, ]
    source_sep_N <- source_top5_percent[source_top5_percent$top2_fc > 2, ]
  }
}

# target
if (T) {
  # statistics for target
  if (T) {
    target_top5_percent <- data.frame(state=unique(dat$target))
    rownames(target_top5_percent) <- target_top5_percent$state
    
    for (t in unique(dat$target)) {
      # t <- "T_1"
      sub_dat <- dat[dat$target == t, ]
      
      sub_dat <- sub_dat[order(sub_dat$Number, decreasing = T), ]
      total <- target[target$state==t, 2]
      
      # top1-5占该state的比例
      target_top5_percent[t, "top1_p"] <- sub_dat$Number[1]/total
      target_top5_percent[t, "top2_p"] <- sub_dat$Number[2]/total
      target_top5_percent[t, "top3_p"] <- sub_dat$Number[3]/total
      target_top5_percent[t, "top4_p"] <- sub_dat$Number[4]/total
      target_top5_percent[t, "top5_p"] <- sub_dat$Number[5]/total
      
      # top1与top2-5之间的fold change
      target_top5_percent[t, "top2_fc"] <- sub_dat$Number[1]/sub_dat$Number[2]
      target_top5_percent[t, "top3_fc"] <- sub_dat$Number[1]/sub_dat$Number[3]
      
      # top1-2对应在source中的state
      target_top5_percent[t, "top1_source"] <- sub_dat$source[1]
      target_top5_percent[t, "top2_source"] <- sub_dat$source[2]
      
      # target中该state总共有多少
      target_top5_percent[t, "target_total"] <- total
    }
  }
  
  # 【target_sep_Y】 filter by target: top1/top2<=2
  # 【target_sep_N】 filter by target: top1/top2>2
  if (T) {
    target_sep_Y <- target_top5_percent[target_top5_percent$top2_fc <= 2, ]
    target_sep_N <- target_top5_percent[target_top5_percent$top2_fc > 2, ]
  }
}

# remove redundent variables
if (T) {
  rm(s, t, total, sub_dat)
  rm(dat, source, target)
}

# classify all states into 8 categories
if (T) {
  # source related statistics
  if (T) {
    state_type <- data.frame()
    for (state in unique(source_top5_percent$state)) {
      # state <- "S_10"
      
      # 1.source是否有被分割：T被分割，F没有被分割
      source_sep_TF <- state %in% source_sep_Y$state
      
      # 找到source中占比top1的部分对应进入到哪个target
      source_sep_top1 <- source_top5_percent[source_top5_percent$state == state, "top1_target"]
      
      # 在上述target的state中，top1的source来自什么state
      source_sep_top1_target_top1 <- target_top5_percent[target_top5_percent$state == source_sep_top1, "top1_source"]
      
      # target是否被分割： F 没有被分割，只有1个主要部分
      target_sep_top1_TF <- source_sep_top1 %in% target_sep_Y$state
      
      # summary
      state_type[state, "state"] <- state
      
      # 该source state是否被分割
      state_type[state, "source_sep_TF"] <- source_sep_TF
      
      # 该source state中top1的部分会去到哪个target state
      state_type[state, "source_sep_top1"] <- source_sep_top1
      
      # 上述找到的target state，作为完整target state时，它的top1 target来源
      state_type[state, "source_sep_top1_target_top1"] <- source_sep_top1_target_top1
      
      # 上述找到的target state，作为完整target state时，是否被分割
      state_type[state, "target_sep_top1_TF"] <- target_sep_top1_TF
    }
    
    rm(state, source_sep_TF, source_sep_top1, source_sep_top1_target_top1, target_sep_top1_TF)
  }
  
  # definition
  if (F) {
    # A_1: source_one_main + target_one_main + target_top1_Y
    # A_2: source_one_main + target_one_main + target_top1_N
    # C_1: source_one_main + target_multiple_main + target_top1_Y
    # C_2: source_one_main + target_multiple_main + target_top1_N
    
    # B_1: source_multiple_main + target_one_main + target_top1_Y
    # B_2: source_multiple_main + target_one_main + target_top1_N
    # D_1: source_multiple_main + target_multiple_main + target_top1_Y
    # D_2: source_multiple_main + target_multiple_main + target_top1_N
  }
  
  # classify
  if (T) {
    colnames(state_type)
    
    # condition
    if (T) {
      # source不分割
      cond1 <- (state_type$source_sep_TF == F)
      
      # source top1对应的target, 该source的top1输出是否是该target的top1
      cond2 <- state_type$state == state_type$source_sep_top1_target_top1
      
      # source top1对应的target不被分割
      cond3 <- (state_type$target_sep_top1_TF == F)
    }
    
    # A, C
    if (T) {
      A_1 <- state_type[(cond1) & (cond2) & (cond3),]
      C_1 <- state_type[(cond1) & (cond2) & (!cond3),]
      
      A_2 <- state_type[(cond1) & (!cond2) & (cond3),]
      C_2 <- state_type[(cond1) & (!cond2) & (!cond3),]
    }
    
    # B, D
    if (T) {
      B_1 <- state_type[(!cond1) & (cond2) & (cond3),]
      D_1 <- state_type[(!cond1) & (cond2) & (!cond3),]
      
      B_2 <- state_type[(!cond1) & (!cond2) & (cond3),]
      D_2 <- state_type[(!cond1) & (!cond2) & (!cond3),]
    }
    
    table(state_type$source_sep_TF)
    nrow(A_1)+nrow(A_2)+nrow(C_1)+nrow(C_2)
    nrow(B_1)+nrow(B_2)+nrow(D_1)+nrow(D_2)
  }
  
  # summary
  if (T) {
    state_type$type <- ifelse(state_type$state %in% A_1$state, "A",
                              ifelse(state_type$state %in% A_2$state, "B",
                                     ifelse(state_type$state %in% B_1$state, "C",
                                            ifelse(state_type$state %in% B_2$state, "D",
                                                   ifelse(state_type$state %in% C_1$state, "E",
                                                          ifelse(state_type$state %in% C_2$state, "F",
                                                                 ifelse(state_type$state %in% D_1$state, "G",
                                                                        ifelse(state_type$state %in% D_2$state, "H","NA"))))))))
    
    
    source_top5_percent$type <- state_type[match(source_top5_percent$state, state_type$state), "type"]
  }
}

# output results
if (T) {
  write.table(source_top5_percent, file = source_top5_percent_file, quote = F, row.names = F, col.names = T, sep = "\t")
  write.table(target_top5_percent, file = target_top5_percent_file, quote = F, row.names = F, col.names = T, sep = "\t")
  write.table(state_type, file = state_type_file, quote = F, row.names = F, col.names = T, sep = "\t")
}

# output the comment
if (T) {
  mess <- c("数据source_top5_percent:",
            "\tstate: source来源的state",
            "\ttop1_p: source来源的state中，占比排名top1的source比例",
            "\ttop2_p: source来源的state中，占比排名top2的source比例",
            "\ttop3_p: source来源的state中，占比排名top3的source比例",
            "\ttop4_p: source来源的state中，占比排名top4的source比例",
            "\ttop5_p: source来源的state中，占比排名top5的source比例",
            "\ttop2_fc: source来源的state中，占比排名top1_p/top2_p（top2_fc<2认为该source来源的state被拆分）",
            "\ttop3_fc: source来源的state中，占比排名top1_p/top3_p",
            "\ttop1_target: source来源的state中，占比排名top1的部分去了新分类中的哪个state（target）",
            "\ttop2_target: source来源的state中，占比排名top2的部分去了新分类中的哪个state（target）",
            "\tsource_total: source来源的state中总共有多少bin数目",
            "\tsum_source_top1_2: source来源的state中，占比排名top1-2的source比例之和",
            "\tsum_source_top1_3: source来源的state中，占比排名top1-3的source比例之和",
            "\tsum_source_top1_4: source来源的state中，占比排名top1-4的source比例之和",
            "\tsum_source_top1_5: source来源的state中，占比排名top1-5的source比例之和",
            "\tpercentage: source来源的state占基因组总bin数的百分比（total=14305237，该值等于source_total/14305237）",
            "\ttype: 具体分类，标准见下",
            "",
            "",
            "数据target_top5_percent:",
            "\tstate: target来源的state",
            "\ttop1_p: target来源的state中，占比排名top1的target比例",
            "\ttop2_p: target来源的state中，占比排名top2的target比例",
            "\ttop3_p: target来源的state中，占比排名top3的target比例",
            "\ttop4_p: target来源的state中，占比排名top4的target比例",
            "\ttop5_p: target来源的state中，占比排名top5的target比例",
            "\ttop2_fc: target来源的state中，占比排名top1_p/top2_p（top2_fc<2认为该target来源的state是由多个来源state合并而成）",
            "\ttop3_fc: target来源的state中，占比排名top1_p/top3_p",
            "\ttop1_source: target来源的state中，占比排名top1的部分是由source中的哪个state构成",
            "\ttop2_source: target来源的state中，占比排名top2的部分是由source中的哪个state构成",
            "\ttarget_total: target来源的state中总共有多少bin数目",
            "",
            "",
            "数据state_type:",
            "\tstate: source来源的state",
            "\tsource_sep_TF: 对于source来源的state是否会被拆分，F意味着不拆分，T意味着拆分",
            "\tsource_sep_top1: source来源的state中，占比排名top1的部分去了新分类中的哪个state（target）",
            "\tsource_sep_top1_target_top1: 对source来源的state中占比排名top1部分所去的state（target），找到其top1部分来源于哪个state（source）",
            "\ttarget_sep_top1_TF: 对source来源的state中占比排名top1部分所去的state（target），判断其是否被拆分（top2_fc<2认为该target来源的state被拆分）",
            "\ttype: 具体分类，标准见下",
            "",
            "",
            "state_type:",
            "\tA(A_1): source不拆分（top2_fc>2）+ source中top1所去state（target）中的top1和top2部分来自该source state + source中top1所去state（target）不拆分（top2_fc>2）",
            "\tE(C_1): source不拆分（top2_fc>2）+ source中top1所去state（target）中的top1和top2部分来自该source state + source中top1所去state（target）被拆分（top2_fc<2）",
            "\tB(A_2): source不拆分（top2_fc>2）+ source中top1所去state（target）中的top1和top2部分不来自该source state + source中top1所去state（target）不拆分（top2_fc>2）",
            "\tF(C_2): source不拆分（top2_fc>2）+ source中top1所去state（target）中的top1和top2部分不来自该source state + source中top1所去state（target）被拆分（top2_fc<2）",
            "",
            "\tC(B_1): source被拆分（top2_fc<2）+ source中top1所去state（target）中的top1和top2部分来自该source state + source中top1所去state（target）不拆分（top2_fc>2）",
            "\tG(D_1): source被拆分（top2_fc<2）+ source中top1所去state（target）中的top1和top2部分来自该source state + source中top1所去state（target）被拆分（top2_fc<2）",
            "\tD(B_2): source被拆分（top2_fc<2）+ source中top1所去state（target）中的top1和top2部分不来自该source state + source中top1所去state（target）不拆分（top2_fc>2）",
            "\tH(D_2): source被拆分（top2_fc<2）+ source中top1所去state（target）中的top1和top2部分不来自该source state + source中top1所去state（target）被拆分（top2_fc<2）")
  write(mess, file = note)
}




