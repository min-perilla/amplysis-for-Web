# 如果没有安装必要的包，则先安装
required_packages <- c("dplyr", "tidyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(dplyr)
library(tidyr)


# 物种组成分析函数
taxa_bar <- function(
    otu,                      # otu 表
    tax,                      # 分类表
    metadata,                 # 分组信息，一般在 metadata，也可以自己编写
    
    id_col = 1,               # OTU 表中的 OTU ID 列的列号，默认为 1
    tax_cla,                  # 分类等级。设置 otu 按照 tax 表中的哪个分类等级合并，可输入列号或者列名，比如 tax_cla = 7,或 tax_cla = "genus"
    
    group1,                   # （必选）分组 1，请输入 metadata 表格里面的分组信息列名或者列号
    group2 = NULL,            # （可选）分组 2，用于分面图，请输入 metadata 表格里面的分组信息列名或者列号
    
    parallel_method,          # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
    row_n                     # 将丰度前 n 的分类保留，其余合并为 "others"
) {
  
  ## 检查形参 group1 和 group2
  # 检查 group1 和 group2 是否在 metadata 表格的列名中
  if (!all(group1 %in% colnames(metadata)) || !all(group2 %in% colnames(metadata))) {
    stop(paste("Some values in", ifelse(!all(group1 %in% colnames(metadata)), "group1", "group2"), "are not present in metadata column names."))
  } else {
    cat("\033[32mgroup1: `", group1, "`\n", 
        "group2: `", group2, "`\033[0m\n", 
        sep = "")
  }
  
  
  ## 格式检查
  # 检查 metadata 数据框是否包含 "sample"，"parallel"
  if ("sample" %in% base::tolower(colnames(metadata)) && 
      "parallel" %in% base::tolower(colnames(metadata))) {
    cat("metadata --> DONE\n")
  } else {
    stop("请确保 metadata 表格中包含 `sample` 列和 `parallel` 列!", 
         "\nsample  ：样品ID（唯一）", 
         "\nparallel：平行样标识")
  }
  
  
  ## 处理 metadata 表
  # 提取 metadata 表格中的名为 "sample", "parallel", 形参 group1 的值, 形参 group2 的值的列
  metadata2 <- metadata[, c("sample", "parallel", group1, group2)]
  
  # 丢弃存在 NA 值的行
  na_rows <- apply(metadata2, 1, function(row) any(is.na(row)))
  # 输出并丢弃 NA 值的行
  if (any(na_rows)) {
    cat("以下行号包含 NA 值并已被丢弃：\n")
    cat(which(na_rows), "\n")
    metadata2 <- metadata2[!na_rows, ]
  } else {
    cat("分组信息中未发现 `NA` 值")
  }
  
  
  ##
  # 检查平行样处理方法
  if(parallel_method == "mean") {
    cat("`metadata` 表中，拥有相同 `parallel` 值的样品视为平行样\n")
    cat("平行样处理方法：mean\n")
    
  } else if(parallel_method == "sum") {
    cat("`metadata` 表中，拥有相同 `parallel` 值的样品视为平行样\n")
    cat("平行样处理方法：sum\n")
    
  } else if(parallel_method == "median") {
    cat("`metadata` 表中，拥有相同 `parallel` 值的样品视为平行样\n")
    cat("平行样处理方法：median\n")
    
  } else if(parallel_method == "none") {
    cat("不处理平行样\n")
    
  } else {
    stop("请输入形参 parallel_method 的正确参数：\n", 
         "根据 `metadata` 表格中的 `parallel` 列进行处理，含有相同 `parallel` 值的样品视为平行样\n", 
         "`mean`  : 取平均\n", 
         "`sum`   : 求和\n", 
         "`median`: 取中位数\n", 
         "`none`  : 不处理平行样\n")
  }


  ##
  # 如果 OTU 表的第一列为 OTU ID，需要将其转换为行名，使得 OTU 表格为纯数字矩阵
  if(id_col > 0) {

    # 转换为 data.frame
    otu <- as.data.frame(otu)
    tax <- as.data.frame(tax)
    # view(otu)
    
    
    ##
    # 根据 metadata2 中 sample 列的值，提取 otu 样本列
    otu_colnames <- (metadata2$sample)
    matching_columns <- which(colnames(otu) %in% otu_colnames)  # 匹配 OTU 表格中的列名
    otu2 <- otu[, c(id_col, matching_columns)]
    
    
    ##
    # 将 tax table 和 otu table 根据 `OTU ID` 列进行左连接
    otu2 <- merge(tax, otu2, by = id_col, all.x = T, sort = F)
    
    # 重命名行名
    rownames(otu2) <- otu2[, id_col]

    # 移除 OTU ID 列
    otu2 <- otu2[, -id_col, drop = FALSE]
    
    cat("otu2 ---> DONE\n")
    # view(otu2)
    
    
  } else { 
    # 无 OTU_ID 列
    
    # 转换为 data.frame
    otu <- as.data.frame(otu)
    tax <- as.data.frame(tax)
    
    
    ##
    # 根据 metadata2 中 sample 列的值，提取 otu 样本列
    otu_colnames <- (metadata2$sample)
    matching_columns <- which(colnames(otu) %in% otu_colnames)  # 匹配 OTU 表格中的列名
    otu2 <- otu[, c(matching_columns)]
    
    # 将 tax table 和 otu table 根据行名进行左连接
    otu2 <- merge(tax, otu2, by = "row.names", all.x = T, sort = F)
    
    # 将第一列转换成行名，并移除第一列
    rownames(otu2) <- otu2[, 1]
    
    # 移除 OTU ID 列
    otu2 <- otu2[, -id_col, drop = FALSE]
    
    cat("otu2 ---> DONE\n")
    # view(otu2)
  }
  ###
  


  
  
  ##
  # 可指定分类水平合并
  otu3 <- otu2 %>%
    dplyr::group_by(dplyr::select(otu2, tidyr::all_of(tax_cla))) %>%                   # 使用 tax 中的分类水平进行分组
    dplyr::summarise_if(is.numeric, sum) %>%                                           # 对每一列进行汇总操作
    dplyr::arrange(dplyr::desc(rowSums(dplyr::across(dplyr::where(is.numeric))))) %>%  # 根据行和，从高到低排序
    dplyr::ungroup()
  # 按照行和从大到小排序
  # 行和
  # rowSums(dplyr::across(dplyr::where(is.numeric)))
  cat("otu3 ---> DONE\n")
  # view(otu3)
  ###
  ##
  

  

  # 将丰度前 n 的分类保留，其余合并为 "others"
  otu4 <- otu3 %>%
    # 添加一个名为 classification 的新列，如果当前行的行号小于等于 row_n，则保持 classification 列的值不变，否则将其设置为 "others"
    dplyr::mutate(ifelse(dplyr::row_number() <= row_n, otu3[[tax_cla]], "others")) 
  
  # 将最后一列取代第一列，并去除最后一列
  otu4[,1] <- otu4[,ncol(otu4)]
  otu4 <- otu4[,-ncol(otu4)]
  
  ##
  otu4 <- otu4 %>%
    dplyr::group_by(dplyr::select(otu4, tidyr::all_of(tax_cla))) %>%      # 按照 classification 列对数据进行分组
    dplyr::summarise_all(sum) %>%                                         # 对每个分组中的数值列进行求和操作
    dplyr::ungroup()
  
  # 对分组后的数据进行排序，确保 "others" 分类在最后
  row_numbers_others <- which(otu4[, 1] == "others")                      # 找出 otu4 数据框第一列值为"others"的行号
  otu4 <- rbind(otu4[-row_numbers_others, ], otu4[row_numbers_others, ])  # 将第一列值为"others"的整行移动到数据框的最后一行
  cat("otu4 ---> DONE\n")
  # view(otu4)
  ##
  

  
  
  
  
  
  ## 转换成长数据格式，并左连接 metadata2 表格
  otu5 <- otu4 %>%
    # 将数据框从宽格式转换为长格式，将除了 classification 列之外的所有列都转换为两列：sample 和 abun
    tidyr::gather(key = "sample", value = "abun", -1) %>%
    dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 otu5 和 metadata2 按照 sample 列进行左连接
  cat("otu5 ---> DONE\n")
  # view(otu5)
  ##

  
  
  
  
  
  ##
  # 处理平行样
  if (parallel_method != "none") {
    otu6 <- otu5 %>%
      # 进行分组
      dplyr::group_by_at(dplyr::vars(all_of(tax_cla), "parallel")) %>%
      dplyr::select(all_of(tax_cla), "parallel", "abun") %>%
      dplyr::summarise_if(is.numeric, match.fun(parallel_method)) %>%
      dplyr::ungroup()
    
    # 再次左连接 metadata2 表格
    metadata3 <- metadata2[, -which(names(metadata2) == "sample")]
    metadata3 <- unique(metadata3) # 去重复
    otu6 <- merge(otu6, metadata3, by = "parallel", all.x = T, all.y = F, sort = F)
    
    cat("parallel_method --> DONE\n")
    cat("otu6 ---> DONE\n")
  } else {
    # 不处理平行样
    otu6 <- otu5
    cat("\033[31mparallelMethod --> NONE\033[0m\n")
    cat("otu6 ---> DONE\n")
  }
  # view(otu6)
  
  ##
  cat("\033[32m--- Please use the `taxa_bar_plot()` function for visualization. ---\n\033[0m")
  return(otu6)
}

