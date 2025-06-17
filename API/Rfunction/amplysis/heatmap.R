# 如果没有安装必要的包，则先安装
required_packages <- c("tidyverse")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

# 加载 R 包
library(tidyverse)

##
# 热图
heatmap <- function(
    otu,                       # otu 表
    tax,                       # 分类表
    metadata,                  # 分组信息，一般在 metadata，也可以自己编写

    id_col = 1,                # OTU 表中的 OTU ID 列的列号，默认为 1
    tax_cla = "genus",         # 分类等级。设置 otu 按照 tax 表中的哪个分类等级合并，可输入列号或者列名，比如 tax_cla = 7,或 tax_cla = "genus"

    group1 = "group",          # （必选）分组 1，请输入 metadata 表格里面的分组信息列名或者列号
    group2 = NULL,             # （可选）分组 2，用于分面图，请输入 metadata 表格里面的分组信息列名或者列号

    replicate_method = "mean",  # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
    row_n = 35                 # 取丰度为前 n 的物种
)
{
  # 处理数据
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
  # 检查 metadata 数据框是否包含 "sample"，"replicate"
  if ("sample" %in% base::tolower(colnames(metadata)) &&
      "replicate" %in% base::tolower(colnames(metadata))) {
    cat("metadata --> DONE\n")
  } else {
    stop("请确保 metadata 表格中包含 `sample` 列和 `replicate` 列!",
         "\nsample  ：样品ID（唯一）",
         "\nreplicate：平行样标识")
  }


  ## 处理 metadata 表
  # 提取 metadata 表格中的名为 "sample", "replicate", 形参 group1 的值, 形参 group2 的值的列
  metadata2 <- metadata[, c("sample", "replicate", group1, group2)]

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


  ## 处理 otu 表
  # 对于 otu，根据分组信息，丢弃相应的列
  sample_values <- c(names(otu)[1], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
  keep_columns <- colnames(otu) %in% sample_values  # 创建一个逻辑向量，表示哪些列应该保留
  otu2 <- otu[, keep_columns]    # 保留 otu 中列名为 TRUE 的列


  ##
  # 检查平行样处理方法
  if(replicate_method == "mean") {
    cat("`metadata` 表中，拥有相同 `replicate` 值的样品视为平行样\n")
    cat("平行样处理方法：mean\n")

  } else if(replicate_method == "sum") {
    cat("`metadata` 表中，拥有相同 `replicate` 值的样品视为平行样\n")
    cat("平行样处理方法：sum\n")

  } else if(replicate_method == "median") {
    cat("`metadata` 表中，拥有相同 `replicate` 值的样品视为平行样\n")
    cat("平行样处理方法：median\n")

  } else if(replicate_method == "none") {
    cat("不处理平行样\n")

  } else {
    stop("请输入形参 replicate_method 的正确参数：\n",
         "根据 `metadata` 表格中的 `replicate` 列进行处理，含有相同 `replicate` 值的样品视为平行样\n",
         "`mean`  : 取平均\n",
         "`sum`   : 求和\n",
         "`median`: 取中位数\n",
         "`none`  : 不处理平行样\n")
  }


  ##
  # 如果 OTU 表的第一列为 OTU ID，需要将其转换为行名，使得 OTU 表格为纯数字矩阵
  if(id_col > 0) {

    # 转换为 data.frame
    otu2 <- as.data.frame(otu2)
    tax <- as.data.frame(tax)


    ##
    # 根据 metadata2 中 sample 列的值，提取 otu 样本列
    otu_colnames <- (metadata2$sample)
    matching_columns <- which(colnames(otu2) %in% otu_colnames)  # 匹配 OTU 表格中的列名
    otu2 <- otu2[, c(id_col, matching_columns)]


    ##
    # 将 tax table 和 otu table 根据 `OTU ID` 列进行左连接
    otu2 <- merge(tax, otu2, by = id_col, all.x = T, sort = F)

    # 重命名行名
    rownames(otu2) <- otu2[, id_col]

    # 移除 OTU ID 列
    otu2 <- otu2[, -id_col, drop = FALSE]

    cat("otu2 ---> DONE\n")


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
  }
  ###


  ##
  # 可指定分类水平合并
  otu3 <- otu2 %>%
    dplyr::group_by(dplyr::select(otu2, tidyr::all_of(tax_cla))) %>%  # 使用 tax 中的分类水平进行分组
    dplyr::summarise_if(is.numeric, sum) %>%       #将相同分类水平的数据相加
    dplyr::arrange(dplyr::desc(rowSums(dplyr::across(dplyr::where(is.numeric))))) %>%  # 根据行和，从高到低排序
    dplyr::ungroup() %>%
    slice(1:row_n)  #挑选丰度前 n 的菌，默认 50
  cat("otu3 ---> DONE\n")
  ###



  ## 转换成长数据格式，并左连接 metadata2 表格
  otu4 <- otu3 %>%
    # 将数据框从宽格式转换为长格式，将除了 classification 列之外的所有列都转换为两列：sample 和 abun
    tidyr::gather(key = "sample", value = "abun", -1) %>%
    dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 otu5 和 metadata2 按照 sample 列进行左连接
  cat("otu4 ---> DONE\n")
  ##


  ##
  # 处理平行样
  if (replicate_method != "none") {
    otu5 <- otu4 %>%
      # 进行分组
      dplyr::group_by_at(dplyr::vars(all_of(tax_cla), "replicate")) %>%
      dplyr::select(all_of(tax_cla), "replicate", "abun") %>%
      dplyr::summarise_if(is.numeric, match.fun(replicate_method)) %>%
      dplyr::ungroup()

    # 再次左连接 metadata2 表格
    metadata3 <- metadata2[, -which(names(metadata2) == "sample")]
    metadata3 <- unique(metadata3) # 去重复
    otu5 <- merge(otu5, metadata3, by = "replicate", all.x = T, all.y = F, sort = F)

    cat("replicate_method --> DONE\n")
    cat("otu5 ---> DONE\n")
    cat("metadata3 ---> DONE\n")
  } else {
    # 不处理平行样
    otu5 <- otu4
    metadata3 = metadata2
    cat("\033[31mreplicateMethod --> NONE\033[0m\n")
    cat("otu5 ---> DONE\n")
    cat("metadata3 ---> DONE\n")
  }


  # 对分组进行合并
  otu6 <- otu5 %>%
    dplyr::group_by(dplyr::select(otu5, tidyr::all_of(tax_cla)),
                    dplyr::select(otu5, tidyr::all_of(group1))) %>%  # 使用 tax 中的分类水平进行分组
    dplyr::summarise_if(is.numeric, sum) %>%       #将相同分类水平的数据相加
    dplyr::arrange(dplyr::desc(rowSums(dplyr::across(dplyr::where(is.numeric))))) %>%  # 根据行和，从高到低排序
    dplyr::ungroup()
  cat("otu6 ---> DONE\n")


  # 将数据从长转换回宽
  otu7 <- otu6 %>%
    # dplyr::select(-dplyr::all_of("replicate")) %>%
    spread(key = {{ group1 }}, value = !!dplyr::sym("abun"))

  ##
  otu7 <- as.data.frame(otu7)         #将数据转换为数据框
  rownames(otu7) <- otu7[, 1]         #设置行名为第一列的值
  otu7 <- otu7[, -1]                  #移除原来的第一列

  # 保留两位小数
  # Round all numeric columns to 3 decimal places
  otu7[] <- lapply(otu7, function(x) if(is.numeric(x)) round(x, 3) else x)
  cat("otu7 ---> DONE\n")
  ##



  ## 根据形参 group2 生成注释文件
  annotation_col = NULL  # 注释化


  if (!is.null(group2) && nzchar(trimws(group2))) {
    # 从 metadata3 中获取 group1 和 group2 对应的列
    annotation_col <- metadata3[, c(group1, group2), drop = FALSE]

    # 去重 group1 所在的列
    annotation_col <- annotation_col[!duplicated(annotation_col[[group1]]), ]

    # 将第一列转换成行名
    annotation_col =  as.data.frame(annotation_col)
    rownames(annotation_col) = annotation_col[, 1]

    # 移除第一列
    annotation_col = annotation_col[, -1, drop = FALSE]

    # 重命名列名为 "Groups"
    colnames(annotation_col) = "Groups"
  }



  ##
  cat("\033[32m--- Please use the `heatmap_plot()` function for visualization. ---\n\033[0m")

  result = NULL

  result = list(
    data = otu7,                     # 绘图数据
    annotation_col = annotation_col  # 列注释文件
  )
  return(result)
}
