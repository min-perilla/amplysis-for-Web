# 如果没有安装必要的包，则先安装
required_packages <- c("dplyr", "tidyr", "vegan")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

# 加载 R 包
library(dplyr)
library(tidyr)
library(vegan)

# PCoA
pcoa <- function(otu,              # otu 表格
                 metadata,         # metadata 表格
                 id_col = 1,       # The OTU_ID column is in which column, defaulting to 0, which means there is no OTU_ID column, and the data is already purely numeric.
                 group = "group",  # group
                 parallel_method = "mean"   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
                ) {
  # 检查形参 group 所表示的列名是否存在于 metadat 中
  if (!all(group %in% colnames(metadata))) {
    stop(paste("Some values in", ifelse(
      !all(group %in% colnames(metadata)), "group"),
      "are not present in metadata column names."))
  } else {
    cat("\033[32mgroup: `", group, "`\n", sep = "")
  }
  
  
  ## 格式检查
  # 检查 metadata 数据框是否包含 "sample"，"parallel"
  if ("sample" %in% base::tolower(colnames(metadata)) &&
      "parallel" %in% base::tolower(colnames(metadata))) {
    cat("metadata --> DONE\n")
  } else {
    stop("Please ensure that the metadata table contains the `sample` column and the `parallel` column!",
         "\nsample: Sample ID (unique)",
         "\nparallel: Parallel sample identifier")
  }
  
  
  ## 处理 metadata 表
  # 提取 metadata 表格中的名为 "sample", "parallel", 形参 group1 的值, 形参 group2 的值的列
  metadata2 <- metadata[, c("sample", "parallel", group)]
  
  # 丢弃存在 NA 值的行
  na_rows <- apply(metadata2, 1, function(row) any(is.na(row)))
  # 输出并丢弃 NA 值的行
  if (any(na_rows)) {
    cat("The following row numbers contain NA values and have been discarded:\n")
    cat(which(na_rows), "\n")
    metadata2 <- metadata2[!na_rows, ]
  } else {
    cat("No 'NA' values found in the grouping information.\n")
  }
  
  
  ## 处理 otu 表
  # 对于 otu，根据分组信息，丢弃相应的列
  sample_values <- c(names(otu)[1], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
  keep_columns <- colnames(otu) %in% sample_values  # 创建一个逻辑向量，表示哪些列应该保留
  otu2 <- otu[, keep_columns]    # 保留 otu 中列名为 TRUE 的列
  
  
  ## 平行样处理
  # 定义允许的方法
  allowedMethods <- base::tolower(c("mean", "sum", "median", "none"))
  
  # 转换为小写
  parallel_method <- base::tolower(parallel_method)
  
  # 检查平行样处理方法
  if(!parallel_method %in% allowedMethods) {
    stop("请输入形参 parallel_method 的正确参数：\n",
         "根据 `metadata` 表格中的 `parallel` 列进行处理，含有相同 `parallel` 值的样品视为平行样\n",
         "`mean`  : 取平均\n",
         "`sum`   : 求和\n",
         "`median`: 取中位数\n",
         "`none`  : 不处理平行样\n")
  } else {
    cat("\033[32mParallel parallel_method: `", parallel_method, "`\n\033[30m", sep = "")
  }
  
  
  ##
  # 处理平行样
  if (parallel_method != "none") {
    ## 转换成长数据格式，并左连接 metadata2 表格
    otu3 <- otu2 %>%
      # 将数据框从宽格式转换为长格式
      tidyr::gather(key = "sample", value = "abun", -1) %>%
      dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 otu3 和 metadata2 按照 sample 列进行左连接
    cat("\033[32motu3 ---> DONE\n\033[30m")
    
    
    otu4 <- otu3 %>%
      # 进行分组
      dplyr::group_by_at(dplyr::vars(names(otu3)[1], dplyr::all_of("parallel"))) %>%
      dplyr::select(names(otu3)[1], dplyr::all_of("parallel"), dplyr::all_of(group), dplyr::all_of("abun")) %>%
      dplyr::summarise_if(is.numeric, ~round(match.fun(parallel_method)(.), 1)) %>%
      dplyr::ungroup()
    cat("\033[32motu4 ---> DONE\n\033[30m")
    
    ## 转换为宽数据
    # 将长格式的数据框 otu4 转换回宽格式
    otu5 <- otu4 %>%
      tidyr::spread(key = names(otu4)[1], value = "abun")
    
    ##
    otu5 <- data.frame(otu5)        # 转化为数据框
    colnames(otu5)[1] <- "#OTU ID"  # 修改第一个列名为“#OTU_ID”
    
    # 转置
    otu5 <- as.data.frame(t(otu5))
    
    # 将行名转换成第一列
    row_names <- row.names(otu5)  # 获取行名
    otu5 <- data.frame(sample = row_names, otu5)  # 将行名作为新的第一列添加到数据框中
    row.names(otu5) <- NULL  # 重置行名
    
    # 将第一行用作列名
    colnames(otu5) <- otu5[1, ]
    # 去除第一行
    otu5 <- otu5[-1, ]
    
    
    ## 恢复原来的排序
    otu6 <- otu5 %>%
      dplyr::arrange(match(otu5[[1]], otu2[[1]]))
    
    cat("\033[32motu6 ---> DONE\n\033[30m")
    
    
    ## 同步 metadata
    metadata3 = metadata2 %>%
      # 保留列名为 "parallel" 和 group 代表的列
      dplyr::select(dplyr::all_of("parallel"), dplyr::all_of(group)) %>%
      # 对 parallel 列去重
      dplyr::distinct(parallel, .keep_all = TRUE)
    # 将第一列改名为 "sample"
    colnames(metadata3)[1] <- "sample"
    
    
    
  } else {
    # 不处理平行样
    
    otu6 = otu2
    metadata3 = metadata2
    cat("\033[32motu6 ---> DONE2\n\033[30m")
    cat("\033[32mmetadata3 ---> DONE2\n\033[30m")
  }
  
  
  ##
  # Obtain the column number of the OTU_ID.
  if(id_col > 0) {
    cat("The column number for 'OTU ID Column' is: ", id_col, "\n", sep = "")
    otu6 <- as.data.frame(otu6)            # Convert to data.frame
    rownames(otu6) <- otu6[, id_col]       # Rename row names
    otu6 <- otu6[, -id_col, drop = FALSE]  # Remove the OTU ID column
    cat("\033[32mid_col ---> DONE\n\033[30m")
  } else {}  # No OTU_ID column

  
  # 转换成数字
  otu6[] <- lapply(otu6, function(x) as.numeric(trimws(x)))
  
  
  ##
  otu_t <- t(otu6)                              # 转置 OTU 表
  
  # 删除常数列或全零列
  otu_t <- otu_t[, apply(otu_t, 2, function(x) var(x) != 0)]
  
  otu.distance <- vegan::vegdist(otu_t)         # 计算 bray_curtis 距离
  pc <- cmdscale(otu.distance, eig = TRUE)      # 执行主坐标分析（PCoA），并保留特征值（eigenvalues）
  
  #计算每个主坐标的贡献率，通过将特征值除以所有特征值的总和并乘以 100 来计算
  PoA <- round(pc$eig / sum(pc$eig) * 100, digits = 2)
  
  PC12 <- as.data.frame(pc$points[, 1:2])                 # 提取前两个主坐标的坐标值
  colnames(PC12) <- c("PC1", "PC2")                       # 重命名为 PC1, PC2
  
  PC12 <- cbind(sample = rownames(PC12), PC12)             # 提取行名作为单独的一列
  PC12 <- merge(PC12, metadata3, by = "sample", sort = F)  # 将 PC12 数据与分组信息合并
  
  # 重命名列名
  colnames(PC12)[colnames(PC12) == group] <- "group"
  
  #返回结果
  result <- list(PCoA = PC12,                   # 绘图数据
                 PoA = PoA)                     # 各主成分解释度
  return(result)
}
