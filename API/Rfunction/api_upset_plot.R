# Upset 图

source("./Rfunction/amplysis/Upset.R")       # 分析函数
source("./Rfunction/amplysis/Upset_plot.R")  # 绘图函数
source("./Rfunction/amplysis/process_metadata.R")  # 处理 metadata 函数


# ------------------------------------------------------------------------------
api_upset_plot <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  ##
  otu <- body$featureData
  metadata <- body$metadata
  cat("OTU table Type: ", class(otu), "\n", sep = "")
  cat("metadata file Type: ", class(metadata), "\n", sep = "")
  
  
  cat("\n前端传入的参数：", "\n", sep = "")
  # 提取分组参数
  group <- body$groupInformation$group
  cat("group", "(", class(group), ")", ": ", group, "\n", sep = "")
  
  # 提取平行样参数
  parallelInformation <- body$parallel$information
  parallel_method <- body$parallel$parallel_method
  cat("Parallel Information", "(", class(parallelInformation), ")", ": ", parallelInformation, "\n", sep = "")
  cat("parallel_method", "(", class(parallel_method), ")", ": ", parallel_method, "\n", sep = "")
  
  # 提取配色参数
  color_matrix <- body$colorSettings$color_matrix   # 条形图配色
  color_point <- body$colorSettings$color_point     # 交点配色
  color_matrix_shade <- body$colorSettings$color_point_bg  # 交点背景色
  color_bar <- body$colorSettings$color_bar         # 柱形图柱子配色
  cat("color_matrix", "(", class(color_matrix), ")", ": ", color_matrix, "\n", sep = "")
  cat("color_point", "(", class(color_point), ")", ": ", color_point, "\n", sep = "")
  cat("color_matrix_shade", "(", class(color_matrix_shade), ")", ": ", color_matrix_shade, "\n", sep = "")
  cat("color_bar", "(", class(color_bar), ")", ": ", color_bar, "\n", sep = "")
  
  # 提取属性参数
  mb_ratio <- as.numeric(body$attribute$mb_ratio)  # 柱形图占比
  cat("mb_ratio", "(", class(mb_ratio), ")", ": ", mb_ratio, "\n", sep = "")
  
  # 提取矩阵参数
  title_matrix_x <- body$matrix$title_matrix_x  # 矩阵图 X 轴名称
  size_title_matrix_x <- as.numeric(body$matrix$matrix_xAxisSize)  # 矩阵图 X 轴字号
  size_title_matrix_y <- as.numeric(body$matrix$matrix_yAxisSize)  # 矩阵图 Y 轴字号
  size_matrix_x <- as.numeric(body$matrix$matrix_labelAxisSize)  # 矩阵图刻度标签大小
  size_point <- as.numeric(body$matrix$matrix_pointSize)  # 矩阵图点的大小
  order_by <- body$matrix$matrix_order  # 矩阵图排序顺序
  
  cat("title_matrix_x", "(", class(title_matrix_x), ")", ": ", title_matrix_x, "\n", sep = "")
  cat("size_title_matrix_x", "(", class(size_title_matrix_x), ")", ": ", size_title_matrix_x, "\n", sep = "")
  cat("size_title_matrix_y", "(", class(size_title_matrix_y), ")", ": ", size_title_matrix_y, "\n", sep = "")
  cat("size_matrix_x", "(", class(size_matrix_x), ")", ": ", size_matrix_x, "\n", sep = "")
  cat("size_point", "(", class(size_point), ")", ": ", size_point, "\n", sep = "")
  cat("order_by", "(", class(order_by), ")", ": ", order_by, "\n", sep = "")
  
  
  # 提取柱形图参数
  title_bar_y <- body$bar$title_bar_y  # 柱形图 Y 轴名称
  size_title_bar_y <- as.numeric(body$bar$bar_yAxisSize)  # 柱形图 Y 轴字号
  size_bar_y <- as.numeric(body$bar$size_bar_y)         # 柱形图刻度标签大小
  size_bar_label = as.numeric(body$bar$size_bar_label)  # bar 图柱子数字大小
  
  custom_order <- body$bar$bar_xAxisOrder  # 柱形图 X 轴自定义排序
  n <- body$bar$bar_barNum  # 柱形图显示的柱子数量
  
  cat("title_bar_y", "(", class(title_bar_y), ")", ": ", title_bar_y, "\n", sep = "")
  cat("size_title_bar_y", "(", class(size_title_bar_y), ")", ": ", size_title_bar_y, "\n", sep = "")
  cat("size_bar_y", "(", class(size_bar_y), ")", ": ", size_bar_y, "\n", sep = "")
  cat("custom_order", "(", class(custom_order), ")", ": ", custom_order, "\n", sep = "")
  cat("n", "(", class(n), ")", ": ", n, "\n", sep = "")
  
  

  # 提取导出参数
  filename <- body$exportSettings$filename
  file_width <- as.numeric(body$exportSettings$file_width)
  file_height <- as.numeric(body$exportSettings$file_height)
  formats <- body$exportSettings$formats
  cat("filename", "(", class(filename), ")", ": ", filename, "\n", sep = "")
  cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  cat("formats", "(", class(formats), ")", ": ", paste(formats, collapse = ", "), "\n", sep = "")
  
  
  # 检查 OTU 和 metadata 的有效性
  if ((is.null(otu) || nrow(otu) == 0 || ncol(otu) == 0) || 
      (is.null(metadata) || nrow(metadata) == 0 || ncol(metadata) == 0)) {
    
    # 分别判断具体的错误并打印消息
    if (is.null(otu) || nrow(otu) == 0 || ncol(otu) == 0) {
      message("错误: OTU 表为空或没有有效数据。")
      otu <- -1
    }
    
    if (is.null(metadata) || nrow(metadata) == 0 || ncol(metadata) == 0) {
      message("错误: Metadata 表为空或没有有效数据。")
      metadata <- -1
    }
    
    # 返回结果
    result <- list(otu = otu, 
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
  
  cat("Metadata 表的纬度: ")
  cat(dim(metadata), "\n")  # 打印行数和列数
  
  
  ## 
  # 预处理参数
  # 预处理 metadata 文件，将缺失值设置为 NA
  metadata = process_metadata(metadata)


  # 处理 color_matrix
  # 检查 color_matrix 是否需要设置为 NULL
  if (!is.null(color_matrix) && (all(color_matrix == "") || all(grepl("^\\s*$", color_matrix)))) {
    color_matrix <- NULL
    
  } else {
    color_matrix = parse_input_vector(color_matrix)
    cat("经过处理后的 color_matrix: ")
  }
  print(color_matrix)
  
  
  # 处理柱形图占比
  # mb_ratio 参数对应着下列分析函数的形参 mb.ratio，mb.ratio 接受 c(0.6, 0.4) 这种类型的数据
  mb.ratio <- c(mb_ratio, 1 - mb_ratio)  # 动态计算另一个比例，使得总和为 1
  # 输出 mb.ratio 的值
  cat("占比形参 mb.ratio: ")
  print(mb.ratio)
  
  
  # 处理柱形图自定义排序
  # 如果 custom_order 非 NULL，但为空字符串，或仅包含空格、换行符等，则将其设置为 NULL
  if (!is.null(custom_order) && (all(custom_order == "") || all(grepl("^\\s*$", custom_order)))) {
    custom_order <- NULL
  }
  
  # 提取字符
  custom_order = parse_input_vector(custom_order)
  cat("经过处理后的 custom_order: ")
  print(custom_order)
  cat("\n")
  
  
  

  # ----------------------------------------------------------------------------
  ##执行函数

  # 数据分析
  data = Upset(
    otu = otu,                          # otu 表格
    metadata = metadata,                # metadata 表格
    id_col = 1,                         # The OTU_ID column is in which column.
    group = group,                      # group
    parallel_method = parallel_method   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
  )
  cat("Upset()：运行成功!", "\n")
  
  
  # 转换为数据框
  data = as.data.frame(data)
  
  
  
  # 绘制图形
  p = Upset_plot(
    data = data,  # 绘图数据
    
    # x 轴色彩
    color_matrix = color_matrix,  # matrix 图中的柱状图配色方案 
    
    n = n,                        # bar 图柱状图显示的柱子数量
    custom_order = custom_order,  # bar 图 x 轴顺序
    order_by = order_by,          # matrix 图排序顺序，可选 "freq" 或 "degree"
    
    # 图形外观
    mb.ratio = mb.ratio,      # bar plot 和 matrix plot 图形高度的占比
    size_point = size_point,  # matrix 图点的大小
  
    color_point = color_point,                # matrix 图点的颜色
    color_matrix_shade = color_matrix_shade,  # matrix 图中阴影部分的颜色
    color_bar = color_bar,                    # bar 图 y 轴柱状图柱子颜色
    
    
    # 标题设置
    title_matrix_x = title_matrix_x,            # matrix 图 x 轴的标签
    title_bar_y = title_bar_y,                  # bar 图 Y 轴标题
    
    
    # 字号设置
    size_title_matrix_x = size_title_matrix_x,  # matrix 图 x 轴标题字号
    size_title_matrix_y = size_title_matrix_y,  # matrix 图 y 轴标题字号
    size_title_bar_y = size_title_bar_y,        # bar 图纵坐标标题字号
    
    size_matrix_x = size_matrix_x,   # matrix 图刻度标签大小
    size_bar_y = size_bar_y,         # bar 图纵坐标刻度字符字号
    size_bar_label = size_bar_label, # bar 图柱子数字大小
    queries = NULL,               # list(), 高亮显示 matrix 图中的特定交集
    
    # 保存文件
    filename = filename,      # 保存文件名
    file_width = file_width,  # 图像宽度
    file_height = file_height # 图像高度
  )
  print(p)  # 预览结果
  
  
  ## 返回 SVG 数据到前端
  # 将 ggplot2 对象生成 SVG 并返回
  svg_output <- svglite::svgstring(
    width = file_width, height = file_height, standalone = TRUE)  # 开启 SVG 图形设备
  print(p)   # 将 ggplot2 对象绘制到 SVG 设备
  if (dev.cur() > 1) dev.off()  # 关闭图形设备
  svg_content <- as.character(svg_output())  # 获取 SVG 字符串内容
  
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    otu = 1,      # 1 表示 otu 不为空
    metadata = 1, # 1 表示 metadata 不为空
    
    data_plot = data,  # 绘图数据
    svg = svg_content  # SVG 图像
  ))
}

