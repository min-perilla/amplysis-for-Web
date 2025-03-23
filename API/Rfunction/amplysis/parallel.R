# 平行样对齐


parallel = function(
    otu, 
    metadata, 
    id_col = 1, 
    group = "group", 
    parallel_method = "mean",
    digits = 0,                # 取平均时，otu 丰度保留的小数位数
    metadata_out = F           # 返回结果将返回一个包含 otu 和 metadata 是 list
) 
{
  
  ## 格式检查（metadata）
  # 标志，该列存在为 1，不存在为 0
  {
    sample_flag = 0
    parallel_flag = 0
    group_flag = 0
  }

  # 检查 metadata 数据框是否包含 "sample"，"parallel"，group 列
  {
    if("sample" %in% base::tolower(colnames(metadata))){ sample_flag = 1 }
    if("parallel" %in% base::tolower(colnames(metadata))){ parallel_flag = 1 }
    if(group %in% colnames(metadata)){ group_flag = 1 }
  }
  
  #
  if(sample_flag == 0 || parallel_flag == 0 || group_flag == 0){
    stop(
      "Please ensure that the metadata table contains the",
      # 无 "sample" 列
      if(sample_flag == 0) { " `sample`" } else { NULL }, 
      # 无 "parallel" 列
      if(parallel_flag == 0) { ", `parallel`" } else { NULL }, 
      # 无 "group" 列
      if(group_flag == 0) { ", `group`" } else { NULL }, 
      " column.\n",
      
      ##
      # 无 "sample" 列
      if(sample_flag == 0) { "\nsample: Sample ID (unique)" } else { NULL }, 
      # 无 "parallel" 列
      if(parallel_flag == 0) { "\nparallel: Parallel sample identifier" } else { NULL }, 
      # 无 "group" 列
      if(group_flag == 0) { "\ngroup: Group information" } else { NULL }, "\n"
      )
  } else { cat("\033[32mmetadata --> DONE\n\033[30m", sep = "") }
  
  
  ## 处理 matadata
  # 提取 metadata 表格中的名为 "sample", "parallel", 形参 group 对应的列
  metadata2 <- metadata[, c("sample", "parallel", group)]
  
  # 丢弃 metadata 中的 group 列存在 NA 值的行
  na_rows <- apply(metadata2, 1, function(row) any(is.na(row)))
  # 输出并丢弃 NA 值的行
  if (any(na_rows)) {
    cat("The following row numbers contain NA values and have been discarded:\n")
    cat(which(na_rows), "\n")
    metadata2 <- metadata2[!na_rows, ]
  } else {
    cat("No 'NA' values found in the grouping information.")
  } 
  
  
  ## 处理行名
  # Obtain the column number of the OTU_ID.
  if(id_col > 0) {
    cat("The column number for 'OTU ID Column' is: ", id_col, "\n", sep = "")
    otu2 = as.data.frame(otu)             # Convert to data.frame
    rownames(otu2) <- otu2[, id_col]      # Rename row names
    otu2 = otu2[, -id_col, drop = FALSE]  # Remove the OTU ID column
    
  } else {
    otu2 = otu
  }  # No OTU_ID column
  
  
  ## 根据 metadata2，丢弃 otu 相应的列
  # 获取 metadata2 中 sample 列的值
  samples_to_keep <- metadata2[["sample"]]
  
  # 找出 otu2 中需要保留的列和需要丢弃的列
  columns_to_keep <- intersect(colnames(otu2), samples_to_keep)
  columns_to_discard <- setdiff(colnames(otu2), samples_to_keep)
  
  # 输出被丢弃的列名
  cat("Columns discarded:", paste(columns_to_discard, collapse = ", "), "\n")
  
  # 过滤 otu2 数据框，只保留指定的列
  otu2 <- otu2[, columns_to_keep, drop = FALSE]
  

  
  
  
  
  
  
  
  ## 处理平行样
  # 定义允许的方法
  allowedMethods <- base::tolower(c("mean", "sum", "median", "none"))
  
  parallel_method = base::tolower(parallel_method)
  
  # 检查平行样处理方法
  if(!base::tolower(parallel_method) %in% allowedMethods) {
    stop("Please enter the correct argument for the parameter 'parallel_method':\n",
         "Process according to the 'parallel' column in the `metadata` table, ",
         "\nsamples with the same 'parallel' value are considered parallel samples.\n",
         "`mean`  : Calculate the average\n",
         "`sum`   : Calculate the sum\n",
         "`median`: Calculate the median\n",
         "`none`  : Do not process parallel samples\n")
    
    
  } else {
    cat("\033[32mparallel_method: `", parallel_method, "`\n\033[30m", sep = "")
  }
  
  
  ##
  if(parallel_method %in% c("mean", "sum", "median")) {
    # 转置,将 otu 转换为数据框，否则使用 group_by 函数会报错
    otu_t <- as.data.frame(t(otu2))
    
    ## 将转置后的丰度表和样本元数据进行左连接，以提取分组信息
    otu_t_g <- merge(otu_t, metadata2, by.x = "row.names", by.y = "sample",
                     all.x = TRUE, sort = F)
    row.names(otu_t_g) <- otu_t_g[, 1]         # 使用 OTU 编号来命名行名
    otu_t_g <- otu_t_g[, -1]                   # 去除第一列
    metadata3 <- otu_t_g[-c(1:ncol(otu_t))]    # 取出分组信息
    
    
    # # 丢弃 metadata3 中的 group 列存在 NA 值的行
    # na_rows <- apply(metadata3, 1, function(row) any(is.na(row)))
    # # 输出并丢弃 NA 值的行
    # if (any(na_rows)) {
    #   # cat("The following row numbers contain NA values and have been discarded:\n")
    #   # cat(which(na_rows), "\n")
    #   
    #   metadata3 <- metadata3[!na_rows, ]
    # } 
    # # else {
    # #   cat("No 'NA' values found in the grouping information.")
    # # } 
    
    
    
    rownames(metadata3) <- NULL                # 初始化行名
    colnames(metadata3)[1] <- "sample"         # 将第一列列名 "parallel" 修改成 "sample"
    
    # 相同分组进行处理：取平均 mean、求和 sum、取中位数 median
    otu_t2 <- otu_t %>%
      dplyr::group_by(metadata3[["sample"]]) %>% 
      #相同分类的进行合并，可选：取平均 mean、求和 sum、取中位数 median
      dplyr::summarize_at(ggplot2::vars(-dplyr::group_cols()), parallel_method)
    
    # 将数据框转换为普通数据框，并设置第一列为行名
    otu_t2 <- as.data.frame(otu_t2)   # 需要转换为数据框，否则使用 row.names 函数会报错
    row.names(otu_t2) <- otu_t2[, 1]  # 设置第一列为行名
    otu_t2 <- otu_t2[, -1]            # 移除第一列，得到最终结果
    
    # 转置回来，即可处理完毕
    otu3 <- as.data.frame(t(otu_t2))
    metadata4 <- unique(as.data.frame(metadata3[["sample"]]))
    colnames(metadata4)[1] <- "sample"
    rownames(metadata4) <- NULL
    
    # 使用 match() 函数找到每个唯一值在原始列中的第一个匹配项的位置
    matched_indices <- match(metadata4[["sample"]], metadata3[["sample"]])
    
    # 根据匹配的位置获取第二列的对应值
    unique_group <- metadata3[[group]][matched_indices]
    
    # 创建一个新的数据框来存储结果
    metadata5 <- data.frame(metadata4, unique_group)
    
    # 重命名列名
    colnames(metadata5) <- c("sample", "group")
    
    # 当取平均时，保留 0 位小数
    if(parallel_method == "mean") {
      otu3 = round(x = otu3, digits = digits)
    }
    
    
    ## 不处理平行样
  } else if(parallel_method %in% c("none")) {
    otu3 <- otu2
    metadata5 <- metadata2
    # 重命名列名
    colnames(metadata5) <- c("sample", "parallel", "group")
  }
  ###
  
  
  
  # 返回 otu 和 metadata
  if(isTRUE(metadata_out)) {
    result = NULL
    result = list(otu = otu3, metadata = metadata5)
  } else {
    
    # 只返回 otu
    return(otu3)
  }
}




