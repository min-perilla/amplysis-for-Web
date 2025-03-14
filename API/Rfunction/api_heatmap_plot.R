# 热图
source("./Rfunction/amplysis/heatmap.R")       # 分析函数
source("./Rfunction/amplysis/heatmap_plot.R")  # 绘图函数
source("./Rfunction/amplysis/parse_input_vector.R")  # 将字符转换为向量


# ------------------------------------------------------------------------------
# 热图
api_heatmap_plot <- function(req) {
  
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  ##
  otu <- body$featureData
  tax <- body$taxonomyData
  metadata <- body$metadata
  cat("OTU table Type: ", class(otu), "\n", sep = "")
  cat("Tax table Type: ", class(tax), "\n", sep = "")
  cat("metadata file Type: ", class(metadata), "\n", sep = "")
  
  cat("\n前端传入的参数：", "\n", sep = "")
  
  # 提取分组参数
  group1 <- body$groupInformation$group1
  group2 <- body$groupInformation$group2
  cat("group 1", "(", class(group1), ")", ": ", group1, "\n", sep = "")
  cat("group 2", "(", class(group2), ")", ": ", group2, "\n", sep = "")
  
  # 提取平行样参数
  parallelInformation <- body$parallel$information
  parallel_method <- body$parallel$parallel_method
  cat("Parallel Information", "(", class(parallelInformation), ")", ": ", parallelInformation, "\n", sep = "")
  cat("parallel_method", "(", class(parallel_method), ")", ": ", parallel_method, "\n", sep = "")
  
  # 提取分类参数
  tax_cla <- body$classification$tax_cla
  row_n <- as.numeric(body$classification$row_n)
  cat("tax_cla", "(", class(tax_cla), ")", ": ", tax_cla, "\n", sep = "")
  cat("row_n", "(", class(row_n), ")", ": ", row_n, "\n", sep = "")
  
  # 提取配色参数
  color <- body$colorSettings$color_scheme
  cat("color", "(", class(color), ")", ": ", color, "\n", sep = "")
  
  # 提取方法参数
  scale <- body$methods$scale
  clustering_method <- body$methods$clustering_method
  cat("scale", "(", class(scale), ")", ": ", scale, "\n", sep = "")
  cat("clustering_method", "(", class(clustering_method), ")", ": ", clustering_method, "\n", sep = "")
  
  # 提取聚类参数
  custom_order <- body$clustering$custom_order
  cluster_cols <- body$clustering$cluster_cols
  clustering_distance_cols <- body$clustering$clustering_distance_cols
  cutree_cols <- as.numeric(body$clustering$cutree_cols)
  cluster_rows <- body$clustering$cluster_rows
  clustering_distance_rows <- body$clustering$clustering_distance_rows
  cat("custom_order", "(", class(custom_order), ")", ": ", custom_order, "\n", sep = "")
  cat("cluster_cols", "(", class(cluster_cols), ")", ": ", cluster_cols, "\n", sep = "")
  cat("clustering_distance_cols", "(", class(clustering_distance_cols), ")", ": ", clustering_distance_cols, "\n", sep = "")
  cat("cutree_cols", "(", class(cutree_cols), ")", ": ", cutree_cols, "\n", sep = "")
  cat("cluster_rows", "(", class(cluster_rows), ")", ": ", cluster_rows, "\n", sep = "")
  cat("clustering_distance_rows", "(", class(clustering_distance_rows), ")", ": ", clustering_distance_rows, "\n", sep = "")
  
  # 提取树状图高度参数
  treeheight_row <- as.numeric(body$treeheight$row)
  treeheight_col <- as.numeric(body$treeheight$col)
  cat("treeheight_row", "(", class(treeheight_row), ")", ": ", treeheight_row, "\n", sep = "")
  cat("treeheight_col", "(", class(treeheight_col), ")", ": ", treeheight_col, "\n", sep = "")
  
  # 提取图表标题参数
  title <- body$titleSettings$title
  cat("title", "(", class(title), ")", ": ", title, "\n", sep = "")
  
  # 提取字体设置参数
  fontsize <- as.numeric(body$fontSettings$fontsize)
  fontsize_row <- as.numeric(body$fontSettings$fontsize_row)
  fontsize_col <- as.numeric(body$fontSettings$fontsize_col)
  row_fontface_italic <- body$fontSettings$row_fontface_italic
  angle_col <- as.numeric(body$fontSettings$angle_col)
  cat("fontsize", "(", class(fontsize), ")", ": ", fontsize, "\n", sep = "")
  cat("fontsize_row", "(", class(fontsize_row), ")", ": ", fontsize_row, "\n", sep = "")
  cat("fontsize_col", "(", class(fontsize_col), ")", ": ", fontsize_col, "\n", sep = "")
  cat("row_fontface_italic", "(", class(row_fontface_italic), ")", ": ", row_fontface_italic, "\n", sep = "")
  cat("angle_col", "(", class(angle_col), ")", ": ", angle_col, "\n", sep = "")
  
  # 提取标签设置参数
  display_numbers <- body$labelSettings$display_numbers
  number_format <- as.numeric(body$labelSettings$number_format)
  number_color <- body$labelSettings$number_color
  cat("display_numbers", "(", class(display_numbers), ")", ": ", display_numbers, "\n", sep = "")
  cat("number_format", "(", class(number_format), ")", ": ", number_format, "\n", sep = "")
  cat("number_color", "(", class(number_color), ")", ": ", number_color, "\n", sep = "")
  
  # 提取图例设置参数
  legend_breaks <- body$legendSettings$legend_breaks
  legend_labels <- body$legendSettings$legend_labels
  cat("legend_breaks", "(", class(legend_breaks), ")", ": ", legend_breaks, "\n", sep = "")
  cat("legend_labels", "(", class(legend_labels), ")", ": ", legend_labels, "\n", sep = "")
  
  # 提取画布参数
  file_width <- as.numeric(body$canvas$file_width)
  file_height <- as.numeric(body$canvas$file_height)
  cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  
  # 提取导出参数
  filename <- body$exportSettings$filename
  file_width <- as.numeric(body$exportSettings$file_width)
  file_height <- as.numeric(body$exportSettings$file_height)
  formats <- body$exportSettings$formats
  cat("filename", "(", class(filename), ")", ": ", filename, "\n", sep = "")
  cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  cat("formats", "(", class(formats), ")", ": ", paste(formats, collapse = ", "), "\n", sep = "")
  
  
  
  # 检查 OTU 和 Tax 表的有效性
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
  
  # 打印数据框的维度和内容
  cat("\nOTU 表的纬度: ")
  cat(dim(otu), "\n")  # 打印行数和列数
  
  cat("Tax 表的纬度: ")
  cat(dim(tax), "\n")  # 打印行数和列数
  
  cat("Metadata 表的纬度: ")
  cat(dim(metadata), "\n")  # 打印行数和列数
  
  
  ## 
  # 预处理参数
  # 处理 group 2
  if (!is.null(group2) && group2 == "NULL") {
    group2 <- NULL
    cat("处理后的 group2: ", sep = "")
    print(group2)
  }
  
  # 处理标题 title
  if (is.null(title) || trimws(title) %in% c("NULL", "")) {
    title <- NA
    cat("处理后的 title: ", sep = "")
    print(title)
  }
  
  # 处理标准化方法 scale
  if(scale == "TRUE") {
    scale = "row"
    cat("处理后的 scale: ", scale, "\n", sep = "")
  } else {
    scale = "none"
    cat("处理后的 scale: ", scale, "\n", sep = "")
  }
  
  # 处理 color
  color = parse_input_vector(color)
  if (length(color) == 0) {
    color =  c("#2196f3", "#a8d1f2", "#f4faff", "#ec9fa2", "#ec1c24")
  }
  cat("经过处理后的 color: ")
  print(color)
  
  
  # 处理 custom_order
  # str(custom_order)
  # 如果 custom_order 非 NULL，但为空字符串，或仅包含空格、换行符等，则将其设置为 NULL
  if (!is.null(custom_order) && (all(custom_order == "") || all(grepl("^\\s*$", custom_order)))) {
    custom_order <- NULL
  }
  
  # 提取字符
  custom_order = parse_input_vector(custom_order)
  cat("经过处理后的 custom_order: ")
  print(custom_order)
  
  
  # 处理参数 cluster_cols：是否开启列聚类
  if(cluster_cols == "TRUE") {
    cluster_cols = TRUE
    cat("处理后的 cluster_cols: ", cluster_cols, "\n", sep = "")
  } else {
    cluster_cols = FALSE
    cat("处理后的 cluster_cols: ", cluster_cols, "\n", sep = "")
  }
  
  # 列聚类簇的数量 cutree_cols
  if(cutree_cols <= 0) {
    cutree_cols = NA
    cat("经过处理后的 cutree_cols: ")
    print(cutree_cols)
  }
  
  # 处理参数 cluster_rows：是否开启行聚类
  if(cluster_rows == "TRUE") {
    cluster_rows = TRUE
    cat("处理后的 cluster_rows: ", cluster_rows, "\n", sep = "")
  } else {
    cluster_rows = FALSE
    cat("处理后的 cluster_rows: ", cluster_rows, "\n", sep = "")
  }
  
  # 处理参数 clustering_rows：是否设置行标题为斜体
  if(row_fontface_italic == "TRUE") {
    row_fontface_italic = TRUE
    cat("处理后的 row_fontface_italic: ", row_fontface_italic, "\n", sep = "")
  } else {
    row_fontface_italic = FALSE
    cat("处理后的 row_fontface_italic: ", row_fontface_italic, "\n", sep = "")
  }
  
  # 提取字符
  print(legend_breaks)
  legend_breaks = parse_input_vector(legend_breaks)
  if (length(legend_breaks) == 0) {
    legend_breaks <- NULL
  }
  cat("经过处理后的 legend_breaks: ")
  print(legend_breaks)
  
  # 提取字符
  print(legend_labels)
  legend_labels = parse_input_vector(legend_labels)
  if (length(legend_labels) == 0) {
    legend_labels <- NULL
  }
  cat("经过处理后的 legend_labels: ")
  print(legend_labels)
  
  # ----------------------------------------------------------------------------
  ##执行函数
  
  # 数据分析
  data = heatmap(
    otu = otu,                          # otu 表
    tax = tax,                          # 分类表
    metadata = metadata,                # 分组信息，一般在 metadata，也可以自己编写
    
    id_col = 1,                         # OTU 表中的 OTU ID 列的列号，默认为 1
    tax_cla = tax_cla,                  # 分类等级。设置 otu 按照 tax 表中的哪个分类等级合并，可输入列号或者列名，比如 tax_cla = 7,或 tax_cla = "genus"
    
    group1 = group1,                    # （必选）分组 1，请输入 metadata 表格里面的分组信息列名或者列号
    group2 = group2,                    # （可选）分组 2，用于分面图，请输入 metadata 表格里面的分组信息列名或者列号
    
    parallel_method = parallel_method,  # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
    row_n = row_n                       # 将丰度前 n 的分类保留，其余合并为 "others"
  )
  cat("heatmap()：运行成功!", "\n")
  
  
  # 绘制图形
  p = heatmap_plot(
    data = data,       # 绘图数据
    scale = scale,     # scale用来设置标准化，row表示横向标准化，column表示列向标准化，none表示不标准化
    cellwidth = NA,    # 表示单个单元格的宽度，默认为 “NA”
    cellheight = NA ,  # 表示单个单元格的高度，默认为 “NA”
    
    # 渐变色
    color =  color,    # 配色
    
    gaps_row = NULL,   # 仅在未进行行聚类时使用，表示在行方向上热图的隔断位置
    gaps_col = NULL,   # 仅在未进行列聚类时使用，表示在列方向上热图的隔断位置
    
    # 聚类设置
    # 列
    custom_order = custom_order,  # 自定义排序列标题顺序。只有当未启用列聚类的时候，才会生效。当不为 NULL 值的时候，会自动禁用列聚类
    cluster_cols = cluster_cols,  # 是否启用列聚类（启用聚类后，无法自定义排序）
    clustering_distance_cols = clustering_distance_cols,  # 列聚类的距离度量
    cutree_cols = cutree_cols,    # 基于层次聚类将列分为多少个簇
    
    # 行
    cluster_rows = cluster_rows,  # 是否启用行聚类
    clustering_distance_rows = clustering_distance_rows,  # 行聚类的距离度量
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
    clustering_method = clustering_method,  # 表示聚类方法，包括：
    # ‘ward.D’, ‘ward.D2’, ‘single’, ‘complete’, ‘average’, ‘mcquitty’, ‘median’, ‘centroid’
    
    # 聚类树
    treeheight_row = treeheight_row,        # 行聚类树高度
    treeheight_col = treeheight_col,        # 列聚类树高度
    
    
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
    title = title,  # 大标题
    
    angle_col = angle_col,  # 列名称旋转角度，可选：0, 45, 90, 270, 315
    
    # 字体
    fontsize = fontsize,    # 热图基本字体大小
    fontsize_row = fontsize_row,  # 行名字体大小
    fontsize_col = fontsize_col,  # 列名字大小  
    row_fontface_italic = row_fontface_italic,  # 行标题默认为斜体
    
    # 图例
    legend_breaks = legend_breaks,  # 设置图例范围。如：c(-1.2, 0, 1.2)
    legend_labels = legend_labels,  # 表示图例断点的标签，与图例范围 legend_breaks 的断点数对应，如：c("Low", "Medium", "High")
    
    # 图形内数字
    display_numbers = display_numbers,  # 是否在每个单元格中显示数字
    number_format = number_format,      # 单元格数字的显示格式。可以直接输入数字（表示保留多少位小数），也可以输入格式，如"%.2f"
    number_color = number_color,        # 单元格数字的颜色
    fontsize_number = 0.8 * fontsize,   # 单元格中数字的字体大小
    
    # 保存文件设置
    filename = filename,       # 保存文件名
    file_width = file_width,   # 图像宽度
    file_height = file_height  # 图像高度
  )
  
  
  ## 返回 SVG 数据到前端
  # 将 ggplot2 对象生成 SVG 并返回
  svg_output <- svglite::svgstring(width = file_width, height = file_height, standalone = TRUE)  # 开启 SVG 图形设备
  print(p)   # 将 ggplot2 对象绘制到 SVG 设备
  if (dev.cur() > 1) dev.off()  # 关闭图形设备
  svg_content <- as.character(svg_output())  # 获取 SVG 字符串内容
  
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    otu = 1,  # 表示 otu 不为空
    tax = 1,  # 表示 tax 不为空
    metadata = 1, # 表示 metadata 不为空
    
    data_plot = data,
    svg = svg_content
  ))
}

