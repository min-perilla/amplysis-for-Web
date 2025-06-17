# 如果没有安装必要的包，则先安装
required_packages <- c("tidyverse", "ggpubr", "vegan", "dplyr",
                       "phyloseq", "multcompView", "picante",
                       "car", "agricolae")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(tidyverse)      # rownames_to_column
library(ggpubr)         # ggplot2 扩展包，用来添加显著性标记，用到 geom_signif
library(vegan)          # 计算多样性
library(dplyr)          # 自定义横坐标顺序，用到 arrange 和 %>%
library(phyloseq)       # 抽平用
library(multcompView)   # 显著性标记：字母标记法
library(picante)        # PD 指数
library(car)            # Q-Q 图
library(agricolae)      # 多重比较


# Alpha 多样性分析
alpha <- function(
    otu,                # otu table
    metadata,           # metadata table
    id_col = 1,         # The OTU_ID column is in which column, defaulting to 0, which means there is no OTU_ID column, and the data is already purely numeric.
    group = "group",    # group
    replicate_method = "none",   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）

    tree = NULL,        # tree file
    method = 1   #对应的方法：
    #            1 Tukey-Hsd
    #            2 Fisher-LSD
    #            3 S-N-K, Student-Newman-Keuls
    #            4 Duncan(new)
    #            5 Scheffe
    #            6 Waller-Duncan
    #            7 REGW
)
{
  # 多重比较方法检查
  if (!method %in% 1:7) {
    stop("Invalid method. Please enter a number between 1 and 7.\n",
         "1: Tukey-Hsd\n",
         "2: Fisher-LSD\n",
         "3: S-N-K, Student-Newman-Keuls\n",
         "4: 4 Duncan(new)\n",
         "5: Scheffe\n",
         "6: Waller-Duncan\n",
         "7: REGW\n")
  } else {
    method_name <- switch(as.character(method),
                          "1" = "Turkey-HSD test",
                          "2" = "Fisher-LSD test",
                          "3" = "Student-Newman-Keuls test",
                          "4" = "Duncan test",
                          "5" = "Scheffe test",
                          "6" = "Waller-Duncan test",
                          "7" = "REGW test")
    cat("method: ", method_name, "\n", sep = "")
  }



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
  # 提取 metadata 表格中的名为 "sample", "replicate", 形参 group1 值的列
  metadata2 <- metadata[, c("sample", "replicate", group)]

  # 丢弃存在 NA 值的行
  na_rows <- apply(metadata2, 1, function(row) any(is.na(row)))
  # 输出并丢弃 NA 值的行
  if (any(na_rows)) {
    cat("The following row numbers contain NA values and have been discarded:\n")
    cat(which(na_rows), "\n")
    metadata2 <- metadata2[!na_rows, ]
  } else {
    cat("No 'NA' values found in the grouping information.")
  }

  ## 处理 otu 表
  # 对于 otu，根据分组信息，丢弃相应的列
  sample_values <- c(names(otu)[1], metadata2[["sample"]])  # 获取 metadata2 中 "sample" 列的值
  keep_columns <- colnames(otu) %in% sample_values  # 创建一个逻辑向量，表示哪些列应该保留
  otu2 <- otu[, keep_columns]    # 保留 otu 中列名为 TRUE 的列





  ##
  # Obtain the column number of the OTU_ID.
  if(id_col > 0) {
    cat("The column number for 'OTU ID Column' is: ", id_col, "\n", sep = "")
    otu2 <- as.data.frame(otu2)            # Convert to data.frame
    rownames(otu2) <- otu2[, id_col]       # Rename row names
    otu2 <- otu2[, -id_col, drop = FALSE]  # Remove the OTU ID column

  } else {}  # No OTU_ID column


  ##
  # 处理平行样
  # 定义允许的方法
  allowedMethods <- base::tolower(c("mean", "sum", "median", "none"))

  # 转换为小写
  replicate_method <- base::tolower(replicate_method)

  # 检查平行样处理方法
  if(!replicate_method %in% allowedMethods) {
    stop("Please enter the correct argument for the parameter 'replicate_method':\n",
         "Process according to the 'replicate' column in the `metadata` table, ",
         "\nsamples with the same 'replicate' value are considered replicate samples.\n",
         "`mean`  : Calculate the average\n",
         "`sum`   : Calculate the sum\n",
         "`median`: Calculate the median\n",
         "`none`  : Do not process replicate samples\n")


  } else {
    cat("\033[32mreplicate replicate_method: `", replicate_method, "`\n\033[30m", sep = "")
  }


  ##
  if(replicate_method %in% c("mean", "sum", "median")) {
    # 处理平行样
    ###
    # 转置,将 otu 转换为数据框，否则使用 group_by 函数会报错
    otu_t <- as.data.frame(t(otu2))

    ## 将转置后的丰度表和样本元数据进行左连接，以提取分组信息
    otu_t_g <- merge(otu_t, metadata2, by.x = "row.names", by.y = "sample",
                     all.x = TRUE, sort = F)
    row.names(otu_t_g) <- otu_t_g[, 1]         # 使用 OTU 编号来命名行名
    otu_t_g <- otu_t_g[, -1]                   # 去除第一列
    metadata3 <- otu_t_g[-c(1:ncol(otu_t))]    # 取出分组信息
    rownames(metadata3) <- NULL                # 初始化行名
    colnames(metadata3)[1] <- "sample"         # 将第一列列名 "replicate" 修改成 "sample"

    # 相同分组进行处理：取平均 mean、求和 sum、取中位数 median
    otu_t2 <- otu_t %>%
      dplyr::group_by(metadata3[["sample"]]) %>%
      #相同分类的进行合并，可选：取平均 mean、求和 sum、取中位数 median
      dplyr::summarize_at(ggplot2::vars(-dplyr::group_cols()), replicate_method)

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

    # 不处理平行样
  } else if(replicate_method %in% c("none")) {
    otu3 <- otu2
    metadata5 <- metadata2
    # 重命名列名
    colnames(metadata5) <- c("sample", "replicate", "group")
  }


  ## 清理 otu3 中值全为 0 的行，或者包含 NA 值的行
  otu3 <- otu3[rowSums(otu3 == 0, na.rm = TRUE) != ncol(otu3), ]  # 去除全为 0 的行
  otu3 <- otu3[complete.cases(otu3), ]  # 去除包含 NA 的行


  ##
  # 计算多样性，MARGIN 用于指定计算多样性的方向，1 表示行，2 表示列
  Shannon <- as.data.frame(vegan::diversity(otu3, index = "shannon", MARGIN = 2, base = exp(1)))
  Simpson <- as.data.frame(vegan::diversity(otu3, index = "simpson", MARGIN = 2, base =  exp(1)))
  Richness <- as.data.frame(vegan::specnumber(otu3, MARGIN = 2)) # spe.rich = sobs

  # 重命名列名
  colnames(Shannon)[1] <- "Shannon"
  colnames(Simpson)[1] <- "Simpson"
  colnames(Richness)[1] <- "Richness"

  # 计算 obs，chao，ace 指数，obs = Richness
  # S.chao1 是 Chao1 指数的一个估计值，se.chao1 则是对 Chao1 指数的标准误估计，ACE 指数同理
  obs_chao_ace <- as.data.frame(t(vegan::estimateR(t(apply(otu3, 2, floor)))))  # 向下取整：apply(otu3, 2, floor)
  Chao1 <- stats::setNames(as.data.frame(obs_chao_ace[, 2]), "Chao1")
  Ace <- stats::setNames(as.data.frame(obs_chao_ace[, 4]), "Ace")
  obs <- stats::setNames(as.data.frame(obs_chao_ace[, 1]), "obs")

  # 计算 Pielou，根据查到的文献，log 的底为 e
  Pielou <- Shannon / log(Richness)
  colnames(Pielou)[1] <- "Pielou_e" # 重命名列名

  # 计算覆盖度
  Goods_coverage <- as.data.frame(1 - colSums(otu3 == 1) / colSums(otu3))
  colnames(Goods_coverage)[1] <- "Goods_coverage" # 重命名列名


  ## 计算 PD 指数
  # 如果输入了树文件，则计算 PD 指数
  if(!is.null(tree)){
    # 处理 OTU 表，给 OTU_ID 这一列的值添加单引号 ''，如 ASV_1 → 'ASV_1'
    otu_pd <- otu3                                    # 复制一个数据框
    row_names <- rownames(otu_pd)                    # 获取数据框的行名
    new_row_names <- paste0("'", row_names, "'")     # 在每个行名前后添加单引号
    rownames(otu_pd) <- new_row_names                # 将新的行名赋值给数据框

    # 转置 OTU 表
    otu_pd_t <- as.data.frame(t(otu_pd))

    cat("即将计算 PD 指数\n", sep = "")

    # 计算 PD 指数
    PD <- picante::pd(otu_pd_t, tree, include.root = TRUE)

    cat("计算完毕\n", sep = "")

    # 重命名
    colnames(PD) <- c("PD", "SR")


    ##
    # 将各多样性指数整合成表格
    index <- cbind(Shannon, Simpson, Chao1, Ace, obs, Richness, Pielou,
                   Goods_coverage, PD)



    ###
    # 系统发育树为空
  } else {
    # 将各多样性指数整合成表格
    index <- cbind(Shannon, Simpson, Chao1, Ace, obs, Richness, Pielou,
                   Goods_coverage)
  }


  ##
  #去第一列出来，拼接到 index 中
  sample = rownames(index)            # 取第一列
  index <- data.frame(sample, index)  # 拼接
  rownames(index) <- NULL             # 初始化行名


  ## 根据列 "sample"，index 左连接 group
  # 使用 merge() 函数进行左连接
  index <- merge(index, metadata5, by = "sample", all.x = TRUE, sort = F)


  ##
  # # 保存文件
  # utils::write.table(index, file = "alpha diversity index.csv", row.names = F,
  #                    col.names = T, sep = ",")
  # ----------------------------------------------------------------------------

  ##
  # 分别提取各 alpha 指数出来
  Shannon <- index[, c("sample", "Shannon", "group")]
  Simpson <- index[, c("sample", "Simpson", "group")]
  Chao1 <- index[, c("sample", "Chao1", "group")]
  Ace <- index[, c("sample", "Ace", "group")]
  Pielou <- index[, c("sample", "Pielou_e", "group")]
  Goods_coverage <- index[, c("sample", "Goods_coverage", "group")]
  if(!is.null(tree)) {
    PD <- index[, c("sample", "PD", "group")]
  }


  ##
  # 将第一列转换成行名
  column_to_rownames <- function(data){
    rownames(data) <- data[, 1]       # Rename row names
    data <- data[, -1, drop = FALSE]  # Remove the OTU ID column\
    return(data)
  }

  Shannon <- column_to_rownames(Shannon)
  Simpson <- column_to_rownames(Simpson)
  Chao1 <- column_to_rownames(Chao1)
  Ace <- column_to_rownames(Ace)
  Pielou <- column_to_rownames(Pielou)
  Goods_coverage <- column_to_rownames(Goods_coverage)
  if(!is.null(tree)) {
    PD <- column_to_rownames(PD)
  }


  ## 显著性分析
  # 验证数据是否符合正态性分布
  Shannon[["group"]] <- factor(Shannon[["group"]])  #将 group 列转换为 factor
  Simpson[["group"]] <- factor(Simpson[["group"]])  #将 group 列转换为 factor
  Chao1[["group"]] <- factor(Chao1[["group"]])      #将 group 列转换为 factor
  Ace[["group"]] <- factor(Ace[["group"]])          #将 group 列转换为 factor
  Pielou[["group"]] <- factor(Pielou[["group"]])    #将 group 列转换为 factor
  Goods_coverage[["group"]] <- factor(Goods_coverage[["group"]])  #将 group 列转换为 factor
  if(!is.null(tree)) {
    PD[["group"]] <- factor(PD[["group"]])            #将 group 列转换为 factor
  }



  ##
  # 根据输入使用相应的多重比较方法
  # 单因素 ANOVA 分析，aov() 函数书写为 aov(y ~ A) 的样式，A 即为因子变量

  # 创建 ANOVA 分析格式
  create_formula <- function(data) {
    # 获取列名
    response_var <- names(data)[1]
    group_var <- names(data)[2]

    # 创建公式
    formula <- stats::as.formula(paste(response_var, "~", group_var))

    return(formula)
  }

  # 开始创建
  formula_shannon <- create_formula(Shannon)
  formula_simpson <- create_formula(Simpson)
  formula_chao1 <- create_formula(Chao1)
  formula_ace <- create_formula(Ace)
  formula_pielou <- create_formula(Pielou)
  formula_goods <- create_formula(Goods_coverage)
  if(!is.null(tree)) {
    formula_pd <- create_formula(PD)
  }


  #
  Shannon_aov <- stats::aov(formula_shannon, data = Shannon)
  Simpson_aov <- stats::aov(formula_simpson, data = Simpson)
  Chao1_aov <- stats::aov(formula_chao1, data = Chao1)
  Ace_aov <- stats::aov(formula_ace, data = Ace)
  Pielou_aov <- stats::aov(formula_pielou, data = Pielou)
  Goods_coverage_aov <- stats::aov(formula_goods, data = Goods_coverage)
  if(!is.null(tree)) {
    PD_aov <- stats::aov(formula_pd, data = PD)
  }


  #
  print(summary(Shannon_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  print(summary(Simpson_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  print(summary(Chao1_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  print(summary(Ace_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  print(summary(Pielou_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  print(summary(Goods_coverage_aov))
  cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n\n")
  if(!is.null(tree)) {
    print(summary(PD_aov))
    cat("Pr(>F) 值低于 0.05 水平则表示有显著差异（整体水平）\n")
  }


  ##
  # 多重比较函数
  multiCompare <- function(data, method) {

    result <- NULL

    # 检查 data 数据框中的缺失值
    # sum(is.na(data))
    data <- na.omit(data)

    switch(as.character(method),
           "1" = {
             # Tukey-HSD
             hsd <- agricolae::HSD.test(y = data, trt = "group", alpha = 0.05)
             print(hsd$groups)
             result <- hsd$groups
           },
           "2" = {
             # Fisher-LSD
             lsd <- agricolae::LSD.test(y = data, trt = "group", alpha = 0.05)
             print(lsd$groups)
             result <- lsd$groups
           },
           "3" = {
             # S-N-K, Student-Newman-Keuls
             snk <- agricolae::SNK.test(y = data, trt = "group", alpha = 0.05)
             print(snk$groups)
             result <- snk$groups
           },
           "4" = {
             # Duncan (new)
             dc <- agricolae::duncan.test(y = data, trt = "group", alpha = 0.05)
             print(dc$groups)
             result <- dc$groups
           },
           "5" = {
             # Scheffe
             scheffe <- agricolae::scheffe.test(y = data, trt = "group", alpha = 0.05)
             print(scheffe$groups)
             result <- scheffe$groups
           },
           "6" = {
             # Waller-Duncan
             waller <- agricolae::waller.test(y = data, trt = "group")
             print(waller$groups)
             result <- waller$groups
           },
           "7" = {
             # REGW
             regw <- agricolae::REGW.test(y = data, trt = "group", alpha = 0.05)
             print(regw$groups)
             result <- regw$groups
           },
           {
             stop("Invalid method. Please enter a number between 1 and 7.")
           }
    )

    return(result)
  }


  # 计算多重比较
  info_Shannon <- multiCompare(Shannon_aov, method)
  info_Simpson <- multiCompare(Simpson_aov, method)
  info_Chao1 <- multiCompare(Chao1_aov, method)
  info_Ace <- multiCompare(Ace_aov, method)
  info_Pielou <- multiCompare(Pielou_aov, method)
  info_Goods_coverage <- multiCompare(Goods_coverage_aov, method)
  if(!is.null(tree)) {
    info_PD <- multiCompare(PD_aov, method)
  }



  ##
  # 处理多重比较信息
  get_differ <- function(info)
  {
    # 将行名变成第一列
    group_info <- rownames(info)
    new_data <- cbind(group_info, info)
    # 移除第二列
    new_data <- new_data[, -2]

    # 重命名列名
    colnames(new_data) <- c("group", "differ")
    # 初始化行名
    rownames(new_data) <- NULL

    return(new_data)
  }

  # 获取标记信息
  differ_Shannon <- get_differ(info_Shannon)
  differ_Simpson <- get_differ(info_Simpson)
  differ_Chao1 <- get_differ(info_Chao1)
  differ_Ace <- get_differ(info_Ace)
  differ_Pielou <- get_differ(info_Pielou)
  differ_Goods_coverage <- get_differ(info_Goods_coverage)
  if(!is.null(tree)) {
    differ_PD <- get_differ(info_PD)
  }



  ##
  # 计算标记位置
  # index_table = Shannon
  # differ = differ_Shannon
  # type = "Shannon"

  differ_position <- function(
    index_table,   # α 多样性指数表格
    differ,        # differ 标记信息表格
    type)          # 指数的类型
  {
    ##
    #提取 index 的行名作为单独一列
    # index_table2 <- index_table %>% tibble::rownames_to_column(var = "#OTU_ID")

    # 复制一份
    index_table2 <- index_table
    # 将行名添加为新列 "sample"
    index_table2$"sample" <- rownames(index_table2)
    # 重置行名
    rownames(index_table2) <- NULL
    # 重新排序列
    index_table2 <- index_table2 %>% select("sample", dplyr::everything())

    # 使用 dplyr 的 left_join() 函数合并 df 和 info
    merged_table <- dplyr::left_join(index_table2, differ, by = c("group" = "group"))


    ##
    # 计算显著性标志 y 轴位置
    max = max(merged_table[, 2])
    min = min(merged_table[, 2])

    # 提取 group 和指数列
    x = merged_table[, c("group", type)]

    # 设置分组信息
    group_x <- "group"

    # 计算每一组 y 的最大值
    # differ_y = x %>%
    #   dplyr::group_by(dplyr::select(x, tidyr::all_of(group_x))) %>%
    #   dplyr::summarise(max(.data[[type]]))
    # differ_y = as.data.frame(differ_y)
    differ_y = x %>%
      dplyr::group_by(dplyr::select(x, tidyr::all_of(group_x))) %>%
      dplyr::summarise(max_value = max(get(type)))
    differ_y = as.data.frame(differ_y)


    # 将分组列命名为行名
    rownames(differ_y) = differ_y$group

    # 重命名列名
    colnames(differ_y) <- c("group", type)

    # 计算位置
    merged_table$differ_y <- differ_y[as.character(merged_table$group), ][[type]] + (max - min) * 0.1

    # 将第一列作为行名
    rownames(merged_table) <- merged_table[, 1]

    # 移除第一列行名
    merged_table <- merged_table[, -1]


    ##
    return(merged_table)
  }

  # 计算标记位置
  # index_table = Shannon
  # differ = differ_Shannon
  # type = "Shannon"
  df_Shannon <- differ_position(Shannon, differ_Shannon, "Shannon")
  df_Simpson <- differ_position(Simpson, differ_Simpson, "Simpson")
  df_Chao1 <- differ_position(Chao1, differ_Chao1, "Chao1")
  df_Ace <- differ_position(Ace, differ_Ace, "Ace")
  df_Pielou <- differ_position(Pielou, differ_Pielou, "Pielou_e")
  df_Goods_coverage <- differ_position(Goods_coverage, differ_Goods_coverage, "Goods_coverage")
  if(!is.null(tree)) {
    df_PD <- differ_position(PD, differ_PD, "PD")
  }



  ##
  result <- NULL
  if(is.null(tree)) {
    result <- list(
      shannon = df_Shannon,
      simpson = df_Simpson,
      chao1 = df_Chao1,
      ace = df_Ace,
      pielou = df_Pielou,
      goods_coverage = df_Goods_coverage)
  } else {
    result <- list(
      shannon = df_Shannon,
      simpson = df_Simpson,
      chao1 = df_Chao1,
      ace = df_Ace,
      pielou = df_Pielou,
      goods_coverage = df_Goods_coverage,
      pd = df_PD)
  }

  return(result)
}

