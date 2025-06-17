# 如果没有安装必要的包，则先安装
required_packages <- c("vegan", "dplyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

#加载包
library(vegan)
library(dplyr)

# 典范对应分析（canonical correspondence analysis, CCA）
CCA <- function(otu,              # OTU
                env,              # 环境因子
                metadata,         # 样本元数据
                id_col = 1,       # OTU ID 列号
                group = "group",  # 分组信息
                replicate_method = "mean"   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
)
{

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
    cat("metadata --> DONE\n")
  } else {
    stop("Please ensure that the metadata table contains the `sample` column and the `replicate` column!",
         "\nsample: Sample ID (unique)",
         "\nreplicate: replicate sample identifier")
  }


  ## 处理 metadata 表
  # 提取 metadata 表格中的名为 "sample", "replicate", 形参 group1 的值, 形参 group2 的值的列
  metadata2 <- metadata[, c("sample", "replicate", group)]

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
  sample_values <- c(names(otu)[id_col], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
  keep_columns <- colnames(otu) %in% sample_values  # 创建一个逻辑向量，表示哪些列应该保留
  otu2 <- otu[, keep_columns]    # 保留 otu 中列名为 TRUE 的列
  cat("\033[32motu2 ---> DONE\n\033[30m")

  ## 处理 env 表
  # 对于 env，根据分组信息，丢弃相应的列
  sample_values_env <- c(names(env)[id_col], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
  keep_columns_env <- env[["sample"]] %in% sample_values_env  # 创建一个逻辑向量，表示哪些列应该保留
  env2 <- env[keep_columns_env, ]    # 保留 env 中列名为 TRUE 的列
  cat("\033[32menv2 ---> DONE\n\033[30m")


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


  ##
  # 处理平行样
  if (replicate_method != "none") {
    ## 转换成长数据格式，并左连接 metadata2 表格
    otu3 <- otu2 %>%
      # 将数据框从宽格式转换为长格式
      tidyr::gather(key = "sample", value = "abun", -1) %>%
      dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 otu3 和 metadata2 按照 sample 列进行左连接
    cat("\033[32motu3 ---> DONE\n\033[30m")


    otu4 <- otu3 %>%
      # 进行分组
      dplyr::group_by_at(dplyr::vars(names(otu3)[1], dplyr::all_of("replicate"))) %>%
      dplyr::select(names(otu3)[1], dplyr::all_of("replicate"), dplyr::all_of(group), dplyr::all_of("abun")) %>%
      dplyr::summarise_if(is.numeric, ~round(match.fun(replicate_method)(.), 1)) %>%
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
    #---------------------------------------------------------------------------





    #---------------------------------------------------------------------------
    ## 处理 env

    # 转置 env
    env_t = t(env2)

    # 处理 env_t 的行名和列名
    colnames(env_t) = env_t[1, ]  # 将第一行转换成列名
    env_t = env_t[-1, ]           # 移除第一行
    cat("\033[32menv_t ---> DONE\n\033[30m")

    env_t_rownames = as.data.frame(rownames(env_t))  # 提取行名成单独一列
    colnames(env_t_rownames) = "env"      # 重命名列名
    env_t2 = cbind(env_t_rownames, env_t)  # 合并
    rownames(env_t2) <- NULL  # 重置行名
    cat("\033[32menv_t2 ---> DONE\n\033[30m")

    ## 转换成长数据格式，并左连接 metadata2 表格
    env_t3 <- env_t2 %>%
      # 将数据框从宽格式转换为长格式
      tidyr::gather(key = "sample", value = "abun", -1) %>%
      dplyr::left_join(metadata2, by = c("sample" = "sample"))  # 将数据框 env_t3 和 metadata2 按照 sample 列进行左连接
    cat("\033[32menv_t3 ---> DONE\n\033[30m")

    # 将 "abun" 列转换成数字
    env_t3["abun"] <- as.numeric(env_t3[["abun"]])

    # str(env_t3)

    env_t4 <- env_t3 %>%
      # 进行分组
      dplyr::group_by_at(dplyr::vars(names(env_t3)[1], dplyr::all_of("replicate"))) %>%
      dplyr::select(names(env_t3)[1], dplyr::all_of("replicate"), dplyr::all_of(group), dplyr::all_of("abun")) %>%
      dplyr::summarise_if(is.numeric, ~round(match.fun(replicate_method)(.), 2)) %>%
      dplyr::ungroup()
    cat("\033[32menv_t4 ---> DONE\n\033[30m")

    ## 转换为宽数据
    # 将长格式的数据框 env_t4 转换回宽格式
    env_t5 <- env_t4 %>%
      tidyr::spread(key = names(env_t4)[1], value = "abun")

    ##
    env_t5 <- data.frame(env_t5)     # 转化为数据框
    colnames(env_t5)[1] <- "env"  # 修改第一个列名为“env”

    # 转置
    env_t5 <- as.data.frame(t(env_t5))

    # 将行名转换成第一列
    row_names <- row.names(env_t5)  # 获取行名
    env_t5 <- data.frame(sample = row_names, env_t5)  # 将行名作为新的第一列添加到数据框中
    row.names(env_t5) <- NULL  # 重置行名

    # 将第一行用作列名
    colnames(env_t5) <- env_t5[1, ]
    # 去除第一行
    env_t5 <- env_t5[-1, ]
    cat("\033[32menv_t5 ---> DONE\n\033[30m")

    ## 恢复原来的排序
    env_t6 <- env_t5 %>%
      dplyr::arrange(match(env_t5[[1]], env_t2[[1]]))

    cat("\033[32menv_t6 ---> DONE\n\033[30m")


    # 转置 env
    env6 = t(env_t6)
    # 处理 env6 的行名和列名
    colnames(env6) = env6[1, ]  # 将第一行转换成列名
    env6 = env6[-1, ]           # 移除第一行

    env_t_rownames = as.data.frame(rownames(env6))  # 提取行名成单独一列
    colnames(env_t_rownames) = "sample"      # 重命名列名
    env6 = cbind(env_t_rownames, env6)  # 合并
    rownames(env6) <- NULL  # 重置行名
    cat("\033[32menv6 ---> DONE\n\033[30m")



    #---------------------------------------------------------------------------
    ## 同步 metadata
    metadata3 = metadata2 %>%
      # 保留列名为 "replicate" 和 group 代表的列
      dplyr::select(dplyr::all_of("replicate"), dplyr::all_of(group)) %>%
      # 对 replicate 列去重
      dplyr::distinct(replicate, .keep_all = TRUE)
    # 将第一列改名为 "sample"
    colnames(metadata3)[1] <- "sample"



  } else {
    # 不处理平行样

    otu6 = otu2
    env6 = env2
    metadata3 = metadata2

    cat("\033[32motu6 ---> DONE2\n\033[30m")
    cat("\033[32menv6 ---> DONE2\n\033[30m")
    cat("\033[32mmetadata3 ---> DONE2\n\033[30m")
  }


  ##
  # Obtain the column number of the OTU_ID.
  if(id_col > 0) {
    cat("The column number for 'OTU ID Column' is: ", id_col, "\n", sep = "")

    otu6 <- as.data.frame(otu6)            # Convert to data.frame
    env6 <- as.data.frame(env6)            # Convert to data.frame

    rownames(otu6) <- otu6[, id_col]       # Rename row names
    rownames(env6) <- env6[, id_col]       # Rename row names

    otu6 <- otu6[, -id_col, drop = FALSE]  # Remove the OTU ID column
    env6 <- env6[, -id_col, drop = FALSE]  # Remove the OTU ID column

    cat("\033[32mid_col ---> DONE\n\033[30m")
  } else {}  # No OTU_ID column


  ## 转换成数字
  otu6[] <- lapply(otu6, function(x) as.numeric(trimws(x)))
  env6[] <- lapply(env6, function(x) as.numeric(trimws(x)))


  ##
  # DCA 检测
  # 使用 decorana 函数检测数据是否适合 RDA 分析
  # 根据 DCA1 的 Axis Lengths 值进行选择
  # 如果 >4.0 选 CCA
  # 如果在 3.0-4.0之间，选 RDA 和 CCA 均可
  # 如果 <3.0，选 RDA

  # DCA Detection
  # Using the decorana function to check if the data is suitable for RDA analysis
  # Selection based on the Axis Lengths value of DCA1
  # If >4.0, choose CCA
  # If between 3.0-4.0, both RDA and CCA are acceptable
  # If <3.0, choose RDA
  DCA <- vegan::decorana(t(otu6))
  print(DCA)
  # cat("当`Axis lengths`值 >4.0 时，选择 CCA；\n
  #      当`Axis lengths`值 介于 3.0-4.0 时，选择 CCA 或 RDA 均可；\n
  #      当`Axis lengths`值 <3.0 时，选择 RDA；\n")
  cat("\033[31mWhen `Axis lengths` value > 4.0, choose CCA;
When `Axis lengths` value is between 3.0 and 4.0, either CCA or RDA can be chosen;
When `Axis lengths` value < 3.0, choose RDA;\n\033[0m")


  ##
  # vegan 包 cca 函数支持 CCA 分析
  df_cca <- vegan::cca(t(otu6) ~ ., env6, , scale = T)

  # 查看 CCA 结果信息，以 I 型标尺为例，具体见参考文章
  scaling1 <- summary(df_cca, scaling = 1)


  ##
  # R2值校正
  R2 <- vegan::RsquareAdj(df_cca)
  # R2_noadj <- R2$r.squared     # 原 R2
  R2_adj <- R2$adj.r.squared   # 校正 R2

  # 计算校正 R2 后的约束轴解释率
  R2_adj_exp <- R2_adj * df_cca$CCA$eig/sum(df_cca$CCA$eig)
  # 计算轴标签数据
  CCA1 <- paste0("CCA1(",round(R2_adj_exp[1]*100, 1),"%)")
  CCA2 <- paste0("CCA2(",round(R2_adj_exp[2]*100, 1),"%)")


  ##约束轴的置换检验及P值校正
  # test <- vegan::anova.cca(df_cca, permutations = 999)                        # 所有约束轴的置换检验，即全局检验，基于 999 次置换，详情 ?anova.cca
  # test_axis <- anova.cca(df_cca, by = 'axis', permutations = 999)             # 各约束轴逐一检验，基于 999 次置换
  # test_axis$`Pr(>F)` <- p.adjust(test_axis$`Pr(>F)`, method = 'bonferroni')   # p值校正（bonferroni为例）


  ##
  # 提取绘图数据
  sites <- data.frame(scaling1$sites)[1:2]

  # 添加分组信息
  sites <- data.frame(sites, rownames(sites))
  colnames(sites) = c("CCA1", "CCA2", "sample")             # 重命名列名
  sites <- dplyr::left_join(sites, metadata3, by = c("sample" = "sample"))  # 将绘图数据和分组合并


  ## 将数据 sites 中的分组列名统一为 “group”
  if (group %in% colnames(sites)) {
    colnames(sites)[colnames(sites) == group] <- "group"
  }


  ## 提取其他数据
  df_env <- data.frame(scaling1$biplot)[1:2]   # 提取环境因子得分


  ## 环境因子与群落结构差异性分析：显著性计算
  # cca_sum <- summary(df_cca)  # 描述统计
  # 检验环境因子相关显著性（Monte Carlo permutation test）
  # df_permutest <- permutest(df_cca, permu = 999) # permu = 999 是表示置换循环的次数
  # 每个环境因子显著性检验
  df_envfit <- vegan::envfit(df_cca, env6, permu = 999)
  # 数据处理
  # cor_data <- data.frame(cca_sum$constr.chi/cca_sum$tot.chi, cca_sum$unconst.chi/cca_sum$tot.chi)
  cor_com <- data.frame(tax = colnames(env6), r = df_envfit$vectors$r, p = df_envfit$vectors$pvals)
  # 将p < 0.05 标记为 FALSE，p > 0.05 标记为 TRUE，使用此数据绘制柱形图。
  cor_com[1:5,3] = cor_com[,3] > 0.05


  # CCA Data
  # Axis Eigenvector 1
  # Axis Eigenvector 2
  # Extract Environmental Factor Scores
  # Analysis of differences between environmental factors and community structure: Significance calculation
  result <- NULL
  result <- list(
    data = sites,      # RDA 数据
    CCA1 = CCA1,       # 轴特征值 1
    CCA2 = CCA2,       # 轴特征值 2
    env = df_env,      # 提取环境因子得分
    cor_com = cor_com  # 环境因子与群落结构差异性分析：显著性计算
  )

  ##
  cat("\033[32m--- Please use the `CCA_plot()` function for visualization. ---\n\033[0m")

  return(result)
}

