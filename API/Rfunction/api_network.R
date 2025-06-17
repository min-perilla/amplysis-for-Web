# 网络分析

source("./Rfunction/amplysis/network.R")       # 分析函数
source("./Rfunction/amplysis/process_metadata.R")  # 处理 metadata 函数


# ------------------------------------------------------------------------------
api_network <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)

  # 提取 OTU 和 Metadata 数据
  otu <- body$featureData
  tax <- body$taxonomyData
  metadata <- body$metadata
  cat("OTU table Type: ", class(otu), "\n", sep = "")
  cat("Tax table Type: ", class(tax), "\n", sep = "")
  cat("Metadata file Type: ", class(metadata), "\n", sep = "")

  cat("\n前端传入的参数：", "\n", sep = "")
  # 提取分组参数
  group <- body$groupInformation$group
  cat("group", "(", class(group), ")", ": ", group, "\n", sep = "")

  # 提取平行样参数
  replicate_method <- body$replicate$replicate_method
  cat("replicate_method", "(", class(replicate_method), ")", ": ", replicate_method, "\n", sep = "")

  # 提取分类信息
  # tax_cla <- body$classification
  # cat("tax_cla", "(", class(tax_cla), ")", ": ", tax_cla, "\n", sep = "")

  # 提取方法参数
  calc_method <- body$calc_method
  .r <- body$r
  .p <- body$p
  cluster_method <- as.numeric(body$cluster_method)
  normalize_flag <- body$normalize
  cat("calc_method", "(", class(calc_method), ")", ": ", calc_method, "\n", sep = "")
  cat(".r", "(", class(.r), ")", ": ", .r, "\n", sep = "")
  cat(".p", "(", class(.p), ")", ": ", .p, "\n", sep = "")
  cat("cluster_method", "(", class(cluster_method), ")", ": ", cluster_method, "\n", sep = "")
  cat("normalize_flag", "(", class(normalize_flag), ")", ": ", normalize_flag, "\n", sep = "")


  ##
  # 检查 OTU, tax 和 metadata 表的有效性
  if ((is.null(otu) || nrow(otu) == 0 || ncol(otu) == 0) ||
      (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) ||
      (is.null(metadata) || nrow(metadata) == 0 || ncol(metadata) == 0)) {

    # 分别判断具体的错误并打印消息
    if (is.null(otu) || nrow(otu) == 0 || ncol(otu) == 0) {
      message("错误: OTU 表为空或没有有效数据。")
      otu <- -1
    }

    if (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) {
      message("错误: Tax 表为空或没有有效数据。")
      tax <- -1
    }

    if (is.null(metadata) || nrow(metadata) == 0 || ncol(metadata) == 0) {
      message("错误: Metadata 表为空或没有有效数据。")
      metadata <- -1
    }


    # 返回结果
    result <- list(otu = otu,
                   tax = tax,
                   metadata = metadata)
    return(result)
  }


  ## OTU 数据类型转换
  # 转换第二列及之后的列为数值类型
  otu <- otu %>%
    mutate(across(2:ncol(otu), as.numeric))  # 从第 2 列到最后一列


  ##
  # 打印数据框的维度和内容
  cat("\nOTU 表的纬度: ")
  cat(dim(otu), "\n")  # 打印行数和列数

  # 打印数据框的维度和内容
  cat("\nTax 表的纬度: ")
  cat(dim(tax), "\n")  # 打印行数和列数

  cat("Metadata 表的纬度: ")
  cat(dim(metadata), "\n")  # 打印行数和列数


  ##
  # 预处理参数
  # 预处理 metadata 文件，将缺失值设置为 NA
  metadata = process_metadata(metadata)


  # 处理 normalize_flag （转换成逻辑值）
  if(normalize_flag == "FALSE") {
    normalize_flag = FALSE
  } else {
    normalize_flag = TRUE
  }
  cat("经过处理后的 normalize_flag", "(", class(normalize_flag), ")", ": ", normalize_flag, "\n", sep = "")



  # ----------------------------------------------------------------------------



  ##执行函数
  # 数据分析
  data = network(
    otu = otu,
    tax = tax,
    metadata = metadata,
    id_col = 1,

    tax_cla = "genus",         # 分类等级，默认为“属”
    label = "phylum",          # 标签信息
    group = group,
    replicate_method = replicate_method,  # 平行样处理方法

    calc_method = calc_method,  # 计算方法，可选：spearman 或 pearson
    cluster_method = cluster_method,        # 聚类方法，可选 1 - 11，默认为 1（Louvain 方法）
    normalize_flag = normalize_flag,     # 是否对 "eigenvector", "closeness", "constraint", "pagerank" 列进行数据标准化处理

    .r = .r,   # 相关性
    .p = .p,  # 显著性


    fileName_edge = "edge",    # 边文件名
    fileName_node = "node"     # 节点文件名 replicate_method = replicate_method   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
  )

  #
  edge = data[["edge"]]
  node = data[["node"]]

  print("node 的结构：")
  class(node)
  cat("\n")
  str(node)



  # 处理 node 中的 NaN 值，确保 DataTables 不会报错


  node[] <- lapply(node, function(x) {
    if (is.numeric(x)) x[is.nan(x)] <- 0  # 只对数值型列处理
    return(x)
  })

  # 确保所有 factor 类型转换为字符，避免 JSON 解析错误
  edge[] <- lapply(edge, function(x) if (is.factor(x)) as.character(x) else x)
  node[] <- lapply(node, function(x) if (is.factor(x)) as.character(x) else x)

  #
  cat("network()：运行成功!", "\n")

  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    otu = 1,      # 1 表示 otu 不为空
    tax = 1,      # 1 表示 tax 不为空
    metadata = 1, # 1 表示 metadata 不为空

    edge = edge,  # 边数据
    node = node   # 节点数据
  ))
}

