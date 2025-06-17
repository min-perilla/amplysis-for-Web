# 如果没有安装必要的包，则先安装
required_packages <- c("igraph", "dplyr", "tidyr", "rlang")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

# 加载 R 包
library(igraph)
library(dplyr)
library(tidyr)
library(rlang)

# 加载依赖函数
source("./Rfunction/amplysis/replicate.R")

##
# 网络分析
network = function(
    otu,
    tax,
    metadata,
    id_col = 1,

    tax_cla = "genus",         # 分类等级，默认为“属”
    label = "phylum",          # 标签信息
    group = "group",
    replicate_method = "none",  # 平行样处理方法

    calc_method = "spearman",  # 计算方法，可选：spearman 或 pearson
    cluster_method = 1,        # 聚类方法，可选 1 - 11，默认为 1（Louvain 方法）
    normalize_flag = TRUE,     # 是否对 "eigenvector", "closeness", "constraint", "pagerank" 列进行数据标准化处理

    .r = 0.6,   # 相关性
    .p = 0.05,  # 显著性


    fileName_edge = "edge",    # 边文件名
    fileName_node = "node"     # 节点文件名
)
{
  # 设置随机种子以确保结果可复现
  # set.seed(seed = seed)

  # 检查计算方法输入是否正确
  valid_methods <- c("spearman", "pearson")  # 定义允许的计算方法

  # 检查聚类方法是否合法
  if (is.na(cluster_method) || cluster_method < 1 || cluster_method > 11) {
    cat("Invalid input. Default method (Louvain) will be used.\n")
    cluster_method <- 1
  }

  # 检查 calc_method 是否在允许的方法列表中
  if (!(calc_method %in% valid_methods)) {
    stop("Error: Calculation method calc_method must be either 'spearman' or 'pearson'.")
  } else {
    cat("\033[32m", "calc_method: ", calc_method, "\033[39m\n", sep = "")
  }


  ## 格式检查（metadata），处理平行样
  otu_metadata = replicate(
    otu = otu, metadata = metadata, id_col = id_col, group = group,
    replicate_method = replicate_method, digits = 0, metadata_out = T)

  # 提取新的 otu 表和 metadata 表
  otu2 = otu_metadata[["otu"]]
  metadata2 = otu_metadata[["metadata"]]



  ## 对齐 otu 和 tax
  otu_tax =  base::merge(
    x = otu2, y = tax,
    by.x = 0, by.y = id_col,
    all.x = F, all.y = F, sort = F)

  # 如果行名单独成列
  if(id_col > 0) {
    ncol_otu = ncol(otu2) + 1
    ncol_tax = ncol(tax) - 1  # 6

    # 行名不是单独成列
  } else if(id_col == 0) {
    ncol_otu = ncol(otu2) + 1
    ncol_tax = ncol(tax)  # 6
  }


  otu2 = otu_tax[, c(1, c(2:ncol_otu))]
  tax2 = otu_tax[, c(1, c((ncol_otu +1):(ncol_otu + ncol_tax)))]


  # 将 otu 表的第一列转换为行名
  row.names(otu2) = otu2[, 1]  # 重命名行名
  otu2 = otu2[, -1]            # 移除第一列


  # 将 tax 表的第一列转换为行名
  row.names(tax2) = tax2[, 1]  # 重命名行名
  tax2 = tax2[, -1]            # 移除第一列
  tax2[is.na(tax2)] <- "unknown"


  ##
  # 将相同分类等级（genus）进行合并
  otu3 <- otu2 %>%                        # 需要转换为数据框，否则使用 row.names 函数会报错
    dplyr::group_by(tax2[[tax_cla]]) %>%  # 根据分类表的分类水平添加分类信息
    # 相同分类的进行合并，求和
    dplyr::summarize_at(dplyr::vars(-dplyr::group_cols()), sum) %>%
    dplyr::arrange(dplyr::desc(rowSums(dplyr::across(dplyr::where(is.numeric))))) %>%  # 根据行和，从高到低排序
    dplyr::ungroup()

  # 将 otu 表的第一列转换为行名
  otu3 = as.data.frame(otu3)
  row.names(otu3) = otu3[, 1]  # 重命名行名
  otu3 = otu3[, -1]            # 移除第一列

  # 去除行都为 0 的行
  zero_sum_rows <- rowSums(otu3 == 0) == ncol(otu3)  # 检查每行的和是否为 0
  otu3_clean <- otu3[!zero_sum_rows, ]               # 去除所有值都为 0 的行

  # 转置
  otu4 <- as.data.frame(t(otu3_clean))         # 转换数据格式


  ##
  # 使用spearman（或pearson）方法计算相关性矩阵
  correlate2 <- function(
    x,
    method = "pearson",  # 默认值为 "pearson" 的 method 参数
    use = "everything",  # 默认值为 "everything" 的 use 参数
    ...                  # 可变参数
  )
  {
    if (!is.matrix(x))       # 如果 x 不是矩阵，则转换为矩阵
      x <- as.matrix(x)

    y = x

    m = n = ncol(x)  # 获取 x 的列数
    r <- stats::cor(x, y, use = use, method = method)  # 计算相关系数矩阵
    p <- matrix(NA, ncol = m, nrow = n, dimnames = list(rownames(r), colnames(r)))  # 创建空的 P 值矩阵
    id <- expand.grid(1:n, 1:m)  # 创建所有可能的索引组合

    # 只获取上三角部分的索引
    id <- id[id$Var1 > id$Var2, , drop = FALSE]

    # 安装 purrr 包
    if (!requireNamespace("purrr", quietly = TRUE)) {
      utils::install.packages("purrr")
    }


    # 对每对索引执行以下操作
    purrr::walk2(id$Var1, id$Var2, function(.idx, .idy) {
      # 计算相关性检验
      tmp <- suppressWarnings(stats::cor.test(x = x[, .idx],
                                       y = y[, .idy],
                                       method = method,
                                       ...))
      p[c(.idx, .idy), c(.idy, .idx)] <<- tmp$p.value  # 将 P 值放入矩阵中对应位置
    })
    diag(p) <- 0  # 将对角线元素设为 0

    # cat("自定义函数1\n")

    # 返回带结构的列表
    structure(
      .Data = list(
        r = r,   # 相关系数矩阵
        p = p),  # P 值矩阵
      class = "correlate"  # 类型为 "correlate"
    )
  }

  # cor_result = edge

  # 将相关性矩阵和 p 值矩阵转换为上三角矩阵格式并去掉对角线元素
  as_upper_tri <- function(cor_result) {
    r <- cor_result$r
    p <- cor_result$p
    upper_triangle_r <- r
    upper_triangle_p <- p
    upper_triangle_r[lower.tri(r, diag = TRUE)] <- NA  # 保留上三角部分并将其他部分设为 NA
    upper_triangle_p[lower.tri(p, diag = TRUE)] <- NA  # 保留上三角部分并将其他部分设为 NA

    # 将相关系数矩阵和 p 值矩阵转换为数据框并去除 NA
    upper_triangle_r <- as.data.frame(as.table(upper_triangle_r))
    upper_triangle_p <- as.data.frame(as.table(upper_triangle_p))

    # 合并相关系数和 p 值
    upper_triangle <- merge(upper_triangle_r, upper_triangle_p, by = c("Var1", "Var2"), sort = F)
    colnames(upper_triangle) <- c(".rownames", ".colnames", "r", "p")

    # 去除 NA 行
    upper_triangle <- na.omit(upper_triangle)
    row.names(upper_triangle) = NULL

    # cat("自定义函数2\n")

    return(upper_triangle)
  }


  ## 网络分析
  # 计算边文件：edge
  edge <- otu4 %>%
    correlate2(method = "spearman") %>%             # 使用 spearman（或pearson）方法计算相关性矩阵
    as_upper_tri() %>%
    # linkET::correlate(method = "spearman") %>%
    # linkET::as_md_tbl(type = "upper", diag = FALSE) %>%  # 将相关性矩阵转换为矩阵格式并保留上三角部分（不包括对角线）
    dplyr::filter(abs(r) >= .r, p <= .p) %>%         # 根据绝对相关系数大于 0.6 且 p 值小于 0.05 来过滤边

    dplyr::mutate(type = "Undirected",             # 添加新列 type，并赋值为 "Undirected"，表示边是无向边
                  id = seq_len(dplyr::n()),        # 添加新列 id，从 1 开始递增，用于标识边的唯一ID
                  label = "",                      # 添加新列 label，并初始化为空
                  sign = ifelse(r > 0, "P", "N"),  # 添加新列 sign，根据相关系数r的正负来判断边的方向，正相关为"P"，负相关为"N"
                  abs_r = abs(r)) %>%              # 添加新列 abs_r，保存相关系数r的绝对值
    dplyr::rename(source = .rownames,              # 重命名列名.rownames 为 source，表示边的起点
                  target = .colnames) %>%          # 重命名列名.colnames 为 target，表示边的终点
    dplyr::select(source, target, type, id, label, r, p, sign, abs_r)  # 选择需要保留的列，包括边的起点、终点、类型、ID、标签、相关系数 r、p 值、方向标识和绝对相关系数




  # 定义函数来重命名列名
  rename_columns <- function(data, old_name, new_name) {
    if (old_name %in% names(data)) {
      data <- data %>%
        rename(!!new_name := !!sym(old_name))
    } else {
      stop(paste("列名", old_name, "不存在"))
    }
    return(data)
  }

  # 假设 .rownames 和 .colnames 是列名字符串
  row_col_name <- ".rownames"
  col_col_name <- ".colnames"

  r <- sym("r")
  p <- sym("p")

  edge1 <- otu4 %>%
    correlate2(method = "spearman") %>%             # 使用 spearman（或pearson）方法计算相关性矩阵
    as_upper_tri() %>%
    # linkET::correlate(method = "spearman") %>%
    # linkET::as_md_tbl(type = "upper", diag = FALSE) %>%  # 将相关性矩阵转换为矩阵格式并保留上三角部分（不包括对角线）
    dplyr::filter(abs(!!r) >= .r, !!p <= .p) %>%           # 根据绝对相关系数大于等于 0.6 且 p 值小于等于 0.05 来过滤边

    dplyr::mutate(type = "Undirected",             # 添加新列 type，并赋值为 "Undirected"，表示边是无向边
                  id = seq_len(dplyr::n()),        # 添加新列 id，从 1 开始递增，用于标识边的唯一ID
                  label = "",                      # 添加新列 label，并初始化为空
                  sign = ifelse(!!r > 0, "P", "N"),  # 添加新列 sign，根据相关系数r的正负来判断边的方向，正相关为"P"，负相关为"N"
                  abs_r = abs(!!r)) %>%              # 添加新列 abs_r，保存相关系数r的绝对值
    rename_columns(row_col_name, "source") %>%     # 重命名列名.rownames 为 source，表示边的起点
    rename_columns(col_col_name, "target") %>%     # 重命名列名.colnames 为 target，表示边的终点
    dplyr::select("source", "target", "type", "id", "label", "r", "p", "sign", "abs_r")  # 选择需要保留的列，包括边的起点、终点、类型、ID、标签、相关系数 r、p 值、方向标识和绝对相关系数





  ## 计算节点文件：node
  {
    edge_igraph <- igraph::graph_from_data_frame(edge, directed = FALSE) # 将边数据转换为 igraph 对象
    node <- igraph::as_data_frame(edge_igraph, "vertices")   # 将 igraph 对象转换为数据框
    }


  ## 给 edge 和 node 文件添加门信息（"label" 列）
  tax3 = tax2[, c(tax_cla, label)]             # 提取列
  tax3 = tax3[!duplicated(tax3[[tax_cla]]), ]  # duplicated() 用来检测哪些元素是重复的
  node = merge(node, tax3, by.x = "name", by.y = "genus", sort = F)
  # 将第二列的列名重命名为 "label"
  colnames(node)[2] = "label"


  ## 计算网络属性
  # 度：dgree
  {
    Degree <- as.data.frame(igraph::degree(edge_igraph, mode = "all", loops = TRUE))  # 计算度
    Degree <- data.frame(row.names(Degree), Degree, row.names = NULL)  # 将行名作为第一列
    colnames(Degree) = c("name", "degree")                             # 重命名
    node <- merge(node, Degree, by = c("name" = "name"), sort = F)     # 将度和 node 表左连接
  }

  # 中介中心性
  {
    Betweenness <- as.data.frame(igraph::betweenness(edge_igraph))
    Betweenness <- data.frame(row.names(Betweenness), Betweenness, row.names = NULL)  # 将行名作为第一列
    colnames(Betweenness) = c("name", "betweenness")                        # 重命名
    node <- merge(node, Betweenness, by = c("name" = "name"), sort = F)     # 左连接
  }

  # 特征向量中心性（Eigenvector Centrality）
  {
    Eigenvector <- as.data.frame(igraph::eigen_centrality(edge_igraph)$vector)
    Eigenvector <- data.frame(row.names(Eigenvector), Eigenvector, row.names = NULL)
    colnames(Eigenvector) = c("name", "eigenvector")
    node <- merge(node, Eigenvector, by = c("name" = "name"), sort = F)
  }

  # 接近中心性（Closeness Centrality）
  {
    Closeness <- as.data.frame(igraph::closeness(edge_igraph))
    Closeness <- data.frame(row.names(Closeness), Closeness, row.names = NULL)
    colnames(Closeness) = c("name", "closeness")
    node <- merge(node, Closeness, by = c("name" = "name"), sort = F)
  }

  # 网络约束（Network Constraint）
  {
    Constraint <- as.data.frame(igraph::constraint(edge_igraph))
    Constraint <- data.frame(row.names(Constraint), Constraint, row.names = NULL)
    colnames(Constraint) = c("name", "constraint")
    node <- merge(node, Constraint, by = c("name" = "name"), sort = F)
  }

  # PageRank，类似于 Google PageRank 算法，用于衡量一个节点的影响力
  {
    PageRank <- as.data.frame(igraph::page_rank(edge_igraph)$vector)
    PageRank <- data.frame(row.names(PageRank), PageRank, row.names = NULL)
    colnames(PageRank) = c("name", "pagerank")
    node <- merge(node, PageRank, by = c("name" = "name"), sort = F)
  }

  # 局部聚集系数（Local Clustering Coefficient）
  {
    ClusteringCoefficient <- as.data.frame(igraph::transitivity(edge_igraph, type = "local"))
    ClusteringCoefficient <- data.frame(row.names(ClusteringCoefficient), ClusteringCoefficient, row.names = NULL)
    colnames(ClusteringCoefficient) = c("name", "clustering_coefficient")
    node <- merge(node, ClusteringCoefficient, by = c("name" = "name"), sort = F)
  }


  # 提示用户选择方法
  cat("You can choose from up to 11 cluster detection methods by entering the corresponding number:\n",
      "1: Louvain (default)\n",
      "2: Edge Betweenness\n",
      "3: Fluid Communities\n",
      "4: Infomap\n",
      "5: Label Propagation\n",
      "6: Leading Eigen\n",
      "7: Leiden\n",
      "8: Optimal\n",
      "9: Spinglass\n",
      "10: Walktrap\n",
      "11: Fast Greedy\n")

  cat("\033[32m", "You are currently using method: ", cluster_method,
      " - ", switch(cluster_method,
                   "1" = "Louvain (default)",
                   "2" = "Edge Betweenness",
                   "3" = "Fluid Communities",
                   "4" = "Infomap",
                   "5" = "Label Propagation",
                   "6" = "Leading Eigen",
                   "7" = "Leiden",
                   "8" = "Optimal",
                   "9" = "Spinglass",
                   "10" = "Walktrap",
                   "11" = "Fast Greedy"),
      "\033[39m\n", sep = "")

  # 选择相应的算法
  Community = switch(
    cluster_method,
    "1" = igraph::cluster_louvain(edge_igraph),
    "2" = igraph::cluster_edge_betweenness(edge_igraph),
    "3" = igraph::cluster_fast_greedy(edge_igraph),
    "4" = igraph::cluster_fluid_communities(edge_igraph, 2),  # 需要指定社区数量
    "5" = igraph::cluster_infomap(edge_igraph),
    "6" = igraph::cluster_label_prop(edge_igraph),
    "7" = igraph::cluster_leading_eigen(edge_igraph),
    "8" = igraph::cluster_leiden(edge_igraph),
    "9" = igraph::cluster_optimal(edge_igraph),
    "10" = igraph::cluster_spinglass(edge_igraph),
    "11" = igraph::cluster_walktrap(edge_igraph)
  )

  # 模块度（Modularity）
  Community2 <- igraph::membership(Community)                                    # 计算群落分配
  Community3 <- as.data.frame(Community2)                                        # 计算群落分配
  Community3 <- data.frame(row.names(Community3), Community3, row.names = NULL)  # 将行名作为第一列
  colnames(Community3) = c("name", "community")                                  # 重命名
  node <- merge(node, Community3, by = c("name" = "name"), sort = F)             # 左连接

  # 计算模块度值
  Modularity = igraph::modularity(Community)
  cat("The modularity of the network using Louvain is:", Modularity, "\n")


  ##
  # 对 "eigenvector", "closeness", "constraint", "pagerank" 列进行标准化
  if(isTRUE(normalize_flag)){
    # 自定义标准化函数
    normalize_by_column_names <- function(data, columns_to_normalize) {
      for (col in columns_to_normalize) {
        if (col %in% colnames(data)) {
          data[[col]] <- (data[[col]] - min(data[[col]])) / (max(data[[col]]) - min(data[[col]])) * 100
        } else {
          cat("Column", col, "not found in the dataset.\n")
        }
      }
      return(data)
    }

    # 指定要标准化的列名
    columns_to_normalize <- c("eigenvector", "closeness", "constraint", "pagerank")

    # 对指定列进行标准化
    node <- normalize_by_column_names(node, columns_to_normalize)
  }


  ##
  # 计算 Zi
  edge_igraph2 = edge_igraph            # 复制

  # z = Ki = rep.int(0, dim(A)[1L])     # 初始化存储节点连接度 z-score 和连接度的向量
  # names(z) = names(Ki) = rownames(A)  # 为结果向量命名

  z = Ki = rep.int(0, igraph::vcount(edge_igraph2))    # 初始化存储模块内连通度的向量
  names(z) = names(Ki) = igraph::V(edge_igraph2)$name  # 重命名


  # 计算每个节点的模块内连通度 K_i
  for (i in V(edge_igraph2)) {
    # 获取节点 i 的 ID
    node_id <- as.numeric(i)

    # 获取节点 i 所在的社区
    comm_i <- Community2[node_id]

    # 获取该社区的所有节点
    nodes_in_comm <- which(Community2 == comm_i)

    # 获取该节点的相邻节点中，属于同一社区的节点数
    Ki[node_id] = length(
      intersect(igraph::neighbors(edge_igraph2, node_id), nodes_in_comm))
  }

  # 转为数据框，测试用
  # Ki = as.data.frame(Ki)


  ##
  # 计算 Ki 的平均值
  N <- max(Community2)          # 计算模块总数
  nS <- tabulate(Community2)    # 计算每个模块中节点的数量

  # 初始化 Ksi 和 sigKsi 向量
  Ksi <- rep(0, max(Community2))
  sigKsi <- rep(0, max(Community2))
  S = NULL


  ##
  # 计算各参数
  for (S in seq_len(max(Community2))) {
    x <- Ki[Community2 == S]  # 获取模块 S 中所有节点的 Ki 值

    if (length(x) > 0) {
      Ksi[S] = mean(unlist(x))   # 计算模块 S 的平均连接度
      sigKsi[S] = stats::sd(unlist(x))  # 计算模块 S 的平均连接度的标准差
    } else {
      Ksi[S] = 0                 # 如果模块 S 中没有节点，平均连接度为0
      sigKsi[S] = 0              # 如果模块 S 中没有节点，标准差为 0
    }
  }



  ###
  # 计算 Zi
  # z-score 值计算公式
  z = (Ki - Ksi[Community2]) / sigKsi[Community2]      # 计算每个节点的连接度 z-score


  ##
  z[is.infinite(z)] = 0                                # 将无穷大的值设为 0
  z[is.nan(z)] = 0                                     # 将 NaN 值设为0
  Zi = z

  # 整合结果
  Zi <- data.frame(Ki, Zi, row.names = names(Ki))       # 将结果存储在数据框中并返回



  ###
  # 计算 Pi
  igraph::V(edge_igraph2)$module = Community2  # 将群落成员身份信息添加到图对象的顶点属性中
  memb <- igraph::vertex_attr(edge_igraph2, "module")  # 提取节点的模块信息
  A <- as.data.frame(igraph::as_adjacency_matrix(edge_igraph2, sparse = FALSE))  # 将图对象 graph 转化为邻接矩阵
  Ki2 = colSums(A)                            # 计算节点的度
  Ki_sum = t(rowsum(A, memb))                 # 计算模块内节点的度之和

  # Pi 计算公式
  Pi = 1 - ((1 / Ki2^2) * rowSums(Ki_sum^2))  # 计算节点的参与系数
  Pi = as.data.frame(Pi)


  ##
  # 合并数据
  Zi_Pi = merge(Zi, Pi, by = "row.names", sort = F)
  Zi_Pi <- na.omit(Zi_Pi)   #NA 值最好去掉，不要当 0 处理


  ##
  # 划分模块
  if(!nrow(Zi_Pi) == 0){
    Zi_Pi[which(Zi_Pi$Zi < 2.5 & Zi_Pi$Pi < 0.62),'type'] <- 'Peripherals'     # 外围节点
    Zi_Pi[which(Zi_Pi$Zi < 2.5 & Zi_Pi$Pi >= 0.62),'type'] <- 'Connectors'     # 连接节点
    Zi_Pi[which(Zi_Pi$Zi >= 2.5 & Zi_Pi$Pi < 0.62),'type'] <- 'Module hubs'    # 模块中枢
    Zi_Pi[which(Zi_Pi$Zi >= 2.5 & Zi_Pi$Pi >= 0.62),'type'] <- 'Network hubs'  # 网络中枢
  }

  # 合并数据
  node2 = merge(node, Zi_Pi, by.x = "name", by.y = "Row.names", sort = F)


  ##
  # 添加自定义 color 信息


  ##
  # 计算各门（形参：label 代表的列名）信息的占比

  ##
  # 输出文件
  fileName_edge = paste0(fileName_edge, ".csv")
  fileName_node = paste0(fileName_node, ".csv")

  # utils::write.csv(x = edge, file = fileName_edge, row.names = F)

  # 将 node 的 "name" 列名改成 "ID"
  names(node2)[names(node2) == "name"] <- "ID"
  # utils::write.csv(x = node2, file = fileName_node,  row.names = F)



  cat("\033[32m--- Please use the `network_plot()` function for visualization. ---\n\033[0m")

  ##
  # 返回结果
  result = NULL
  result = list(
    edge = edge,
    node = node2
  )
  return(result)
}


