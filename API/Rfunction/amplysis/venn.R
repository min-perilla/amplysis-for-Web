# 如果没有安装必要的包，则先安装
required_packages <- c("dplyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(dplyr)

# Venn
venn = function(otu,                       # otu 表格
                metadata = NULL,           # metadata 表格
                id_col = 1,                # The OTU_ID column is in which column.
                group = "group",           # group
                replicate_method = "mean"   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
                # write_file = F             # 是否导出分析数据
                )
{
  # 允许 metadata 为空。当 metadata 为空时，形参 group 将失效
  if(!is.null(metadata)) {
    # 检查形参 group 所表示的列名是否存在于 metadata 中
    if (!all(group %in% colnames(metadata))) {
      stop(paste("Some values in", ifelse(
        !all(group %in% colnames(metadata)), "group"),
        "are not present in metadata column names."))
    } else {
      cat("\033[32mgroup: `", group, "`\n\033[30m", sep = "")
    }


    ## 格式检查
    # 检查 metadata 数据框是否包含 "sample"，"replicate"
    if ("sample" %in% base::tolower(colnames(metadata)) &&
        "replicate" %in% base::tolower(colnames(metadata))) {
      cat("\033[32mmetadata --> DONE\n\033[30m")
    } else {
      stop("Please ensure that the metadata table contains the `sample` column and the `replicate` column!",
           "\nsample: Sample ID (unique)",
           "\nreplicate: replicate sample identifier")
    }


    ## 处理 metadata 表
    # 提取 metadata 表格中的名为 "sample", "replicate", 形参 group1 的值, 形参 group2 的值的列
    metadata2 <- metadata[, c("sample", "replicate", group)]

    # 对于 metadata，丢弃存在 NA 值的行
    na_rows <- apply(metadata2, 1, function(row) any(is.na(row)))

    # 输出并丢弃 NA 值的行
    if (any(na_rows)) {
      cat("metadata: The following row numbers contain NA values and have been discarded:\n")
      cat(which(na_rows), "\n")

      # 丢弃 metadata 中对应的行
      metadata2 <- metadata2[!na_rows, ]

    } else {
      cat("metadata: No 'NA' values found in the grouping information.\n")
    }

    # 对于 otu，根据分组信息，丢弃相应的列
    sample_values <- c(names(otu)[1], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
    keep_columns <- colnames(otu) %in% sample_values  # 创建一个逻辑向量，表示哪些列应该保留
    otu2 <- otu[, keep_columns]    # 保留 otu 中列名为 TRUE 的列




    ## 平行样处理
    # 定义允许的方法
    allowedMethods <- base::tolower(c("mean", "sum", "median", "none"))

    # 转换为小写
    replicate_method <- base::tolower(replicate_method)

    # 检查平行样处理方法
    if(!replicate_method %in% allowedMethods) {
      stop("请输入形参 replicate_method 的正确参数：\n",
           "根据 `metadata` 表格中的 `replicate` 列进行处理，含有相同 `replicate` 值的样品视为平行样\n",
           "`mean`  : 取平均\n",
           "`sum`   : 求和\n",
           "`median`: 取中位数\n",
           "`none`  : 不处理平行样\n")
    } else {
      cat("\033[32mreplicate replicate_method: `", replicate_method, "`\n\033[30m", sep = "")
    }


    ## 转换成长数据格式，并左连接 metadata2 表格
    otu3 <- otu2 %>%
      # 将数据框从宽格式转换为长格式
      tidyr::gather(key = "sample", value = "abun", -1) %>%
      dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 otu3 和 metadata2 按照 sample 列进行左连接
    cat("\033[32motu3 ---> DONE\n\033[30m")


    ##
    # 合并分组
    if (replicate_method != "none") {
      otu4 <- otu3 %>%
        # 进行分组
        dplyr::group_by_at(dplyr::vars(names(otu3)[1], dplyr::all_of(group))) %>%
        dplyr::select(names(otu3)[1], group, "abun") %>%
        dplyr::summarise_if(is.numeric, match.fun(replicate_method)) %>%
        dplyr::ungroup()
      cat("\033[32motu4 ---> DONE\n\033[30m")
    } else {
      otu4 <- otu3[ , setdiff(names(otu3), c("sample", "replicate"))]  # 移除列 "sample", "replicate"
      cat("\033[32motu4 ---> DONE2\n\033[30m")
    }


    ## 转换为宽数据
    # 将长格式的数据框 otu4 转换回宽格式
    otu5 <- otu4 %>%
      tidyr::spread(key = names(otu4)[1], value = "abun")


    ##
    otu5 <- data.frame(otu5)        # 转化为数据框
    colnames(otu5)[1] <- "#OTU_ID"  # 修改第一个列名为“#OTU_ID”

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


  } else {
    # 当 metadata 为 NULL 时
    otu5 <- otu
  }


  ##
  # Obtain the column number of the OTU_ID.
  if(id_col > 0) {
    cat("The column number for 'OTU ID Column' is: ", id_col, "\n", sep = "")
    otu5 <- as.data.frame(otu5)            # Convert to data.frame
    rownames(otu5) <- otu5[, id_col]       # Rename row names
    otu5 <- otu5[, -id_col, drop = FALSE]  # Remove the OTU ID column

  }


  # ##
  # # 导出分析数据
  # if(isTRUE(write_file)) {
  #   # 初始化列表
  #   df <- NULL
  #
  #   ##
  #   # 获取每个样本（组）中所有的OTU
  #   for (i in 1:length(colnames(otu5))){
  #     group <- colnames(otu5)[i]
  #     df[[group]] <- rownames(otu5)[which(otu5[,i]!= 0)]
  #   }
  #
  #   # 提取交集信息
  #   inter <- VennDiagram::get.venn.partitions(df)
  #
  #   # 处理交集信息
  #   for (i in 1:nrow(inter)){
  #     inter[i,'values'] <- paste(inter[[i,'..values..']], collapse = ', ')
  #   }
  #
  #   # 去除多余的数据列
  #   inter2 <- inter[, setdiff(names(inter), c("..set..", "..values.."))]
  #
  #
  #   # 保存文件
  #   # utils::write.csv(inter2, file = "Venn_inter.csv", row.names = FALSE)  # 保存数据框到 CSV 文件
  # }


  # 返回结果
  return(otu5)
}



