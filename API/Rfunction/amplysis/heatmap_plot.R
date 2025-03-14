# 如果没有安装必要的包，则先安装
required_packages <- c("tidyverse", "pheatmap")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

# 加载 R 包
library(tidyverse)
library(pheatmap)


##
# 可视化
heatmap_plot <- function(
    data,              # 绘图数据
    scale = "row",     # scale用来设置标准化，row表示横向标准化，column表示列向标准化，none表示不标准化
    cellwidth = NA,    # 表示单个单元格的宽度，默认为 “NA”
    cellheight = NA ,  # 表示单个单元格的高度，默认为 “NA”
    
    # 渐变色
    color =  c("#2196f3", "#a8d1f2", "#f4faff", "#ec9fa2", "#ec1c24"),
    
    gaps_row = NULL,     # 仅在未进行行聚类时使用，表示在行方向上热图的隔断位置
    gaps_col = NULL,     # 仅在未进行列聚类时使用，表示在列方向上热图的隔断位置

    # 聚类设置
    # 列
    custom_order = NULL,  # 自定义排序列标题顺序。只有当未启用列聚类的时候，才会生效。当不为 NULL 值的时候，会自动禁用列聚类
    cluster_cols = F,     # 是否启用列聚类（启用聚类后，无法自定义排序）
    clustering_distance_cols = "euclidean",  # 列聚类的距离度量
    cutree_cols = NA,  # 基于层次聚类将列分为多少个簇

    # 行
    cluster_rows = T,     # 是否启用行聚类
    clustering_distance_rows = "euclidean",  # 行聚类的距离度量
    # clustering_distance_rows 和 clustering_distance_cols 的可选参数：
    # 1 - "euclidean"   : 欧几里得距离，最常用的距离度量方式。
    # 2 - "correlation" : 相关系数距离，基于皮尔逊相关系数来计算距离。
    # 3 - "maximum"     : 切比雪夫距离（最大距离），计算点之间的最大坐标差。
    # 4 - "manhattan"   : 曼哈顿距离（城市街区距离），计算点之间的绝对坐标差之和。
    # 5 - "canberra"    : 坎贝拉距离，基于坐标差的绝对值与坐标和之比，适用于稀疏数据。
    # 6 - "binary"      : 二进制距离，计算数据的二进制形式的差异。
    # 7 - "minkowski"   : 闵可夫斯基距离，欧几里得距离的推广。
    cutree_rows = NA,  # 基于层次聚类将行分为多少个簇
    
    # 聚类方法
    clustering_method = "ward.D",  # 表示聚类方法，包括：‘ward.D’, ‘ward.D2’, ‘single’, ‘complete’, ‘average’, ‘mcquitty’, ‘median’, ‘centroid’
    
    # 聚类树
    treeheight_row = 50,           # 行聚类树高度
    treeheight_col = 50,           # 列聚类树高度
    
    
    ## 注释
    # 列（可以开发成使用 metadata 中的第二分组）
    annotation_col = NA,   # (data.frame) 列注释。当为 NULL 或 NA 的时候，启用默认的根据 group2 生成的列注释。
    # 也可以自定义输入数据，如：
    # annotation_col <- data.frame(
    #     Groups = c("A", "A", "A", "B", "B", "B", "D", "D", "D", "R", "R", "R"),
    #     row.names = colnames(data[["data"]]))
    
    # 行（保留一个接口，可以使用单独的 csv 文件进行注释）
    annotation_row = NA,  # (data.frame) 行注释。请输入两列数据，第一列为热图的行名，第二列为注释信息。
    
    # 注释颜色
    annotation_colors = NA, # (list or vector) 列注释轨道颜色。可以输入list或者vector。例子如下：
    # 向量形式（列注释）：annotation_colors = c("A" = "purple", "B" = "orange", "R" = "pink", "D" = "yellow")
    # list 形式（包含列注释和行注释）：
    # annotation_colors = list(
    #   Groups = c("A" = "purple", "B" = "orange", "R" = "pink", "D" = "yellow")  # 列注释颜色
    #   Type = c("A" = "blue", "B" = "green", "C" = "red")     # 行注释颜色
    # )

    # 图
    title = "Heatmap",             # 大标题
    
    angle_col = 0,                 # 列名称旋转角度，可选：0, 45, 90, 270, 315
    
    # 字体
    fontsize = 18,                 # 热图基本字体大小
    fontsize_row = 16,             # 行名字体大小
    fontsize_col = 18,             # 列名字大小  
    row_fontface_italic = T,       # 行标题默认为斜体
    
    # 图例
    legend_breaks = NA,            # 设置图例范围。如：c(-1.2, 0, 1.2)
    legend_labels = NA,            # 表示图例断点的标签，与图例范围 legend_breaks 的断点数对应，如：c("Low", "Medium", "High")
    
    # 图形内数字
    display_numbers = F,               # 是否在每个单元格中显示数字
    number_format = "%.2f",            # 单元格数字的显示格式。可以直接输入数字（表示保留多少位小数），也可以输入格式，如"%.2f"
    number_color = "grey30",           # 单元格数字的颜色
    fontsize_number = 0.8 * fontsize,  # 单元格中数字的字体大小
    
    # 保存文件设置
    filename = "heatmap",          # 保存文件名
    file_width = 12,               # 图像宽度
    file_height = 12               # 图像高度
)
{
  # 关闭绘图器，防止没有输出
  if (dev.cur() > 1) dev.off()
  
  # 绘图数据
  mat = data[["data"]]

  
  ## 列注释数据
  flag_annotation_col = FALSE  # 用来标记是否启用了自定义列注释
  
  # annotation_col = read_data("annotation_col.csv")
  
  # 检查 annotation_col 是否有效，是否为 NULL、空字符串、空格字符串或者包含 NA
  if (is.null(annotation_col) || 
      (is.character(annotation_col) && trimws(annotation_col) == "") ||  # 检查是否为空字符串或仅包含空格
      any(is.na(annotation_col)) || 
      (is.data.frame(annotation_col) && nrow(annotation_col) == 0)) {
    # 启用默认的注释
    annotation_col = data[["annotation_col"]]
    cat("启用默认列注释", "\n", sep = "")
    if (is.null(annotation_col)) {
      annotation_col = NA
    }
    
    
    ## 自定义列注释
  } else {
    flag_annotation_col = TRUE  # 用来标记是否启用了自定义列注释
    cat("启用自定义列注释", "\n", sep = "")

    # annotation_col = read_data("annotation_col.csv")
    
    # 处理数据
    annotation_col = as.data.frame(annotation_col)
    rownames(annotation_col) = annotation_col[, 1]       # 将第一列命名成行名
    annotation_col = annotation_col[, -1, drop = FALSE]  # 移除第一列
  }
  
  
  ##
  # 注释轨道配色处理（处理成列表的形式）
  
  # 如果没有启动自定义列注释
  if(isFALSE(flag_annotation_col)) {
    col_name = colnames(data[["annotation_col"]])[1]  # 取第一列的列名
    
  } else {  # 如果启动了自定义列注释
    col_name = colnames(annotation_col)[1]  # 取第一列的列名
  }
  
  
  # 检查 annotation_colors 是否为 NULL 或 NA
  if (is.null(annotation_colors) || all(is.na(annotation_colors))) {
    annotation_colors = NULL
  } else {
    # 判断 annotation_colors 是向量还是 list
    if (!is.list(annotation_colors)) {
      # 如果是向量，则转换为 list 并设置名称
      annotation_colors = setNames(list(annotation_colors), col_name)
    } else {
      # 如果本来就是 list，则直接修改名称
      names(annotation_colors)[1] = col_name
    }
  }

  
  ## 配色
  color = grDevices::colorRampPalette(color)(100) # 渐变色
  # ----------------------------------------------------------------------------
  
  # custom_order = c("A", "B", "R", "D")
  # custom_order = c(1, 2, 4, 3)
  # custom_order = NULL
  # 如果 custom_order 不是 NULL，进行手动排序
  if (!is.null(custom_order)) {
    # 禁用列聚类
    cluster_cols = FALSE
    cat("\033[31m列聚类：禁用（已启用自定义列排序）\033[0m\n")
    
    # 如果 custom_order 是字符向量（即列名），则转换为列索引
    if (is.character(custom_order)) {
      if (!all(custom_order %in% colnames(mat))) {
        stop("Error: 指定的 custom_order 包含不存在的列名，请检查输入!")
      }
      # 转换为列索引
      cat("Custom order: ", custom_order, "\n", sep = " ")
      custom_order <- match(custom_order, colnames(mat))
      cat("Custom order: ", custom_order, "(column number)\n", sep = " ")
      
      
      ## 如果已经是列索引，则应该输出相应的列名，方便用户参考
    } else {
      # 输出列索引
      cat("Custom order: ", paste(custom_order, collapse = " "), "\n", sep = "")
      # 转换为相应的列名
      custom_order_names <- colnames(mat)[custom_order]
      # 输出列名
      cat("Custom order: ", paste(custom_order_names, collapse = " "), " (column name)\n", sep = "")
    }
    
    
    ##
    # 按行标准化，四舍五入到 2 位小数，并转置
    matrix2 <- round(t(apply(mat, MARGIN = 1, base::scale)), 2)
    
    # 恢复 matrix2 的列名
    colnames(matrix2) <- colnames(mat)
    
    # 将 matrix2 转换为数据框
    exprTable <- as.data.frame(t(matrix2))
    
    # 计算欧氏距离
    row_dist <- stats::dist(exprTable, method = "euclidean")
    
    # 层次聚类
    hclust_1 <- stats::hclust(row_dist)
    
    # 设定自定义列顺序
    hclust_1[[3]] <- custom_order
    
    # 赋值给 cluster_cols
    cluster_cols2 <- hclust_1
    
    
    ## 未启用自定义排序
  } else {
    
    ## 禁用列聚类
    if(isFALSE(cluster_cols)) {
      cluster_cols2 = cluster_cols
      cat("\033[31m", "列聚类：禁用（用户手动禁用）", "\033[0m", "\n", sep = "")
    }
    
    cat("\033[31m", "自定义排序：禁用", "\033[0m", "\n", sep = "")
    cat("若要自定义热图列排序，请使用形参 \"custom_order\"\n", 
        "如：custom_order = c(\"A\", \"B\", \"R\", \"D\")\n", sep = "")
  }
  
  
  ## 输出当前列聚类状态
  # 启用列聚类
  if (isTRUE(cluster_cols)) {
    cluster_cols2 = cluster_cols
    cat("\033[32m", "列聚类：启用", "\033[0m", "\n", sep = "")
    
    ## 聚类方法格式检查
    valid_methods <- c("ward.D", "ward.D2", "single", "complete", "average", "mcquitty", "median", "centroid")
    
    if (!(clustering_method %in% valid_methods)) {
      stop("Invalid clustering method. Please choose from \n", 
           "'ward.D', 'ward.D2', 'single', 'complete', 'average', 'mcquitty', 'median', or 'centroid'.")
    } else {
      cat("列聚类的方法：", clustering_method, "\n", sep = "")
    }
    
    cat("若要自定义热图列排序，请使用形参 \"custom_order\"\n", 
        "如：custom_order = c(\"A\", \"B\", \"R\", \"D\")\n", sep = "")
  } 
  # ----------------------------------------------------------------------------
  
  
  
  
  # ----------------------------------------------------------------------------
  # 行、列聚类的距离度量方法：用一个向量来对应
  distance_methods <- c(
    "euclidean",   # 1: 欧几里得距离
    "correlation", # 2: 皮尔逊相关系数距离
    "maximum",     # 3: 切比雪夫距离
    "manhattan",   # 4: 曼哈顿距离
    "canberra",    # 5: 坎贝拉距离
    "binary",      # 6: 二进制距离
    "minkowski"    # 7: 闵可夫斯基距离
  )
  
  # 更新距离度量方法的函数
  set_clustering_distance <- function(distance_param) {
    # 如果输入是字符串，则直接匹配
    if (is.character(distance_param)) {
      if (distance_param %in% distance_methods) {
        return(distance_param)
      } else {
        stop("Error: 提供的距离度量方法无效。请输入有效的字符串：'euclidean', 'correlation', 'maximum', 'manhattan', 'canberra', 'binary', 'minkowski'.")
      }
    }
    
    # 如果输入是数字，则转换为对应的字符串
    if (is.numeric(distance_param)) {
      # 自动取余，确保数字在有效范围内
      distance_method <- distance_methods[(distance_param - 1) %% length(distance_methods) + 1]
      return(distance_method)
    }
    
    stop("Error: 输入类型无效。请输入字符串或数字。")
  }
  
  # 通过数字或字符串映射来更新距离度量方法
  clustering_distance_cols <- set_clustering_distance(clustering_distance_cols)
  clustering_distance_rows <- set_clustering_distance(clustering_distance_rows)
  
  # 输出选定的距离度量方法（包括数字与名称）
  cat("列聚类的距离度量方法：", which(distance_methods == clustering_distance_cols), " - ", clustering_distance_cols, "\n", sep = "")
  cat("行聚类的距离度量方法：", which(distance_methods == clustering_distance_rows), " - ", clustering_distance_rows, "\n", sep = "")
  
  # 计算已选择的距离度量方法
  selected_methods <- c(clustering_distance_cols, clustering_distance_rows)
  
  # 输出剩余可选择的距离度量方法及简短介绍
  cat("\n其他可选择的距离度量方法：\n")
  for (i in 1:length(distance_methods)) {
    # 如果该方法已经被选择，则跳过
    if (distance_methods[i] %in% selected_methods) {
      next
    }
    
    # 输出未选择的距离度量方法
    # 使用sprintf来对齐输出，确保冒号对齐
    cat(sprintf("%-2d- %-12s: %s\n", i, distance_methods[i], 
                switch(i,
                       "1" = "欧几里得距离",
                       "2" = "皮尔逊相关系数距离",
                       "3" = "切比雪夫距离，计算点之间的最大坐标差",
                       "4" = "曼哈顿距离，计算点之间的绝对坐标差之和",
                       "5" = "坎贝拉距离，适用于稀疏数据的度量方式",
                       "6" = "二进制距离，计算数据二进制形式的差异",
                       "7" = "闵可夫斯基距离，欧几里得距离的推广"
                )), sep = "")
  }
  cat("\n")
  # ----------------------------------------------------------------------------
  
  
  
  ###
  if (!requireNamespace("pheatmap", quietly = TRUE)) {
    stop("The 'pheatmap' package is required but not installed. Please install
         it using 'install.packages(\"pheatmap\")'.")
  }
  
  
  ##
  # 预处理：图形内数字
  # 根据用户输入动态生成格式
  # number_format = "%.3f"
  
  # 判断输入类型并处理
  if (is.numeric(number_format)) {
    number_format <- paste0("%.", number_format, "f")
  } else if (is.character(number_format) && grepl("^%\\.\\d+f$", number_format)) {
    number_format <- number_format
  } else {
    stop("Error: 输入格式无效。请输入整数（小数位数）或格式字符串（如 '%.2f'）")
  }
  
  
  # 预处理：文件名
  filename = paste0(filename, ".png")
  
  
  # 让所有行名称变成斜体
  if(isTRUE(row_fontface_italic)) {
    labels_row <- parse(text = paste0("italic('", rownames(mat), "')"))
  } else {
    # 标准字体
    labels_row = NULL
  }
  
  # 让列名变成粗体
  labels_col <- parse(text = paste0("bold('", colnames(mat), "')"))

  
  
  ## 可视化
  # 关闭绘图器，防止没有输出
  if (dev.cur() > 1) dev.off()
  
  
  
  # 绘制热图
  p <- pheatmap::pheatmap(
    mat = mat, 
    scale = scale, 
    
    # 单元格美化
    border_color = "white",   # 设置格子边框为白色
    cellwidth = cellwidth,    # 表示单个单元格的宽度\高度，默认为 “NA”
    cellheight = cellheight,  # 表示单个单元格的宽度\高度，默认为 “NA”
    color = color,  #颜色
    # gaps_row = NULL,        # 仅在未进行行聚类时使用，表示在行方向上热图的隔断位置
    # gaps_col = c(1, 2, 3, 4),  # 仅在未进行列聚类时使用，表示在列方向上热图的隔断位置
    gaps_row = gaps_row,      # 仅在未进行行聚类时使用，表示在行方向上热图的隔断位置
    gaps_col = gaps_col,      # 仅在未进行列聚类时使用，表示在列方向上热图的隔断位置
    
    
    
    # 聚类设置
    # 列
    cluster_cols = cluster_cols2,  # 列聚类
    clustering_distance_cols = clustering_distance_cols,  # 列聚类的距离度量
    cutree_cols = cutree_cols,        # 基于层次聚类将列分为多少个簇
    
    # 行
    cluster_rows = cluster_rows,   # 行聚类，默认启用
    clustering_distance_rows = clustering_distance_rows,  # 行聚类的距离度量
    cutree_rows = cutree_rows,        # 基于层次聚类将行分为多少个簇
    
    # 聚类方法
    clustering_method = clustering_method,     # 表示聚类方法，包括：‘ward.D’, ‘ward.D2’, ‘single’, ‘complete’, ‘average’, ‘mcquitty’, ‘median’, ‘centroid’
    
    # 聚类树
    treeheight_row = treeheight_row,  # 行聚类树高度调整
    treeheight_col = treeheight_col,  # 列聚类树高度调整
    
    
    ## 注释
    # 列（可以开发成使用 metadata 中的第二分组）
    annotation_col = annotation_col, 
    
    # 行（保留一个接口，可以使用单独的 csv 文件进行注释）
    annotation_row = annotation_row,
    
    # 注释颜色
    annotation_colors = annotation_colors,
    

    # 标题
    main = title,                              # 表示热图的标题名字
    
    # 字体大小
    fontsize = fontsize,                       # 热图中字体大小
    fontsize_row = fontsize_row,               # 行名字体大小
    fontsize_col = fontsize_col,               # 列名字大小      
    
    # 横纵坐标
    labels_row = labels_row,                   # 表示使用行标签代替行名
    labels_col = labels_col,                   # 表示使用列标签代替列名
    angle_col = angle_col,                     # 列名称旋转角度
    
    
    # 图例
    # legend = F,                                # 去掉图例
    # legend_breaks = c(-1.2, 0, 1.2),           # 设置图例范围
    # legend_labels = c("Low", "Medium", "High"),  # 表示图例断点的标签
    legend_breaks = legend_breaks,             # 设置图例范围
    legend_labels = legend_labels,             # 表示图例断点的标签
    
    # 图形内数字
    display_numbers = display_numbers,  # 是否在每个单元格中显示数字
    number_format = number_format,      # 单元格数字的显示格式
    number_color = number_color,        # 单元格数字的颜色
    fontsize_number = fontsize_number,  # 单元格中数字的字体大小
    
    # silent = TRUE,
    
    # 保存文件
    # filename = filename, 
    width = file_width, height = file_height
  )
  
  
  cat("\033[32mheatmap: success!\033[0m\n")
  cat("\033[0;32m", "The file \"", filename, "\" has been saved to \n", 
      getwd(), "/", filename, "\033[0m\n", sep = "")
  
  # 关闭绘图器，防止没有输出
  if (dev.cur() > 1) dev.off()
  print(p)

  return(p)
}

