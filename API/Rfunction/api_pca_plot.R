# PCA 图

source("./Rfunction/amplysis/pca.R")       # 分析函数
source("./Rfunction/amplysis/pca_plot.R")  # 绘图函数
source("./Rfunction/amplysis/process_metadata.R")  # 处理 metadata 函数


# ------------------------------------------------------------------------------
api_pca_plot <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  # 提取 OTU 和 Metadata 数据
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
  cat("parallelInformation", "(", class(parallelInformation), ")", ": ", parallelInformation, "\n", sep = "")
  cat("parallel_method", "(", class(parallel_method), ")", ": ", parallel_method, "\n", sep = "")
  
  # 提取颜色信息
  color_scheme <- body$color$color_scheme
  cat("color_scheme", "(", class(color_scheme), ")", ": ", color_scheme, "\n", sep = "")
  
  # 提取标题信息
  title <- body$title$title
  size_title <- as.numeric(body$title$size_title)
  cat("title", "(", class(title), ")", ": ", title, "\n", sep = "")
  cat("size_title", "(", class(size_title), ")", ": ", size_title, "\n", sep = "")
  
  # 提取副标题信息
  title_sub <- body$subTitle$title_sub
  size_title_sub <- as.numeric(body$subTitle$size_title_sub)
  cat("title_sub", "(", class(title_sub), ")", ": ", title_sub, "\n", sep = "")
  cat("size_title_sub", "(", class(size_title_sub), ")", ": ", size_title_sub, "\n", sep = "")
  
  # 提取数字标签信息
  label_is <- body$label$label_is
  size_label <- as.numeric(body$label$size_label)
  cat("label_is", "(", class(label_is), ")", ": ", label_is, "\n", sep = "")
  cat("size_label", "(", class(size_label), ")", ": ", size_label, "\n", sep = "")
  
  # 提取点大小
  size_point <- as.numeric(body$size_point)
  cat("size_point", "(", class(size_point), ")", ": ", size_point, "\n", sep = "")
  
  # 提取坐标轴信息
  size_title_x <- as.numeric(body$xAxis$size_title_x)
  size_x <- as.numeric(body$xAxis$size_x)
  cat("size_title_x", "(", class(size_title_x), ")", ": ", size_title_x, "\n", sep = "")
  cat("size_x", "(", class(size_x), ")", ": ", size_x, "\n", sep = "")
  
  size_title_y <- as.numeric(body$yAxis$size_title_y)
  size_y <- as.numeric(body$yAxis$size_y)
  cat("size_title_y", "(", class(size_title_y), ")", ": ", size_title_y, "\n", sep = "")
  cat("size_y", "(", class(size_y), ")", ": ", size_y, "\n", sep = "")
  
  # 提取图例信息
  title_legend <- body$legend$title_legend
  size_title_legend <- as.numeric(body$legend$size_title_legend)
  size_legend <- as.numeric(body$legend$size_legend)
  size_point_legend <- as.numeric(body$legend$size_point_legend)
  spacing_legend_point <- as.numeric(body$legend$spacing_legend_point)
  spacing_legend_title <- as.numeric(body$legend$spacing_legend_title)
  legend_ncol <- as.numeric(body$legend$legend_ncol)
  custom_order <- body$legend$custom_order
  
  cat("title_legend", "(", class(title_legend), ")", ": ", title_legend, "\n", sep = "")
  cat("size_title_legend", "(", class(size_title_legend), ")", ": ", size_title_legend, "\n", sep = "")
  cat("size_legend", "(", class(size_legend), ")", ": ", size_legend, "\n", sep = "")
  cat("size_point_legend", "(", class(size_point_legend), ")", ": ", size_point_legend, "\n", sep = "")
  cat("spacing_legend_point", "(", class(spacing_legend_point), ")", ": ", spacing_legend_point, "\n", sep = "")
  cat("spacing_legend_title", "(", class(spacing_legend_title), ")", ": ", spacing_legend_title, "\n", sep = "")
  cat("legend_ncol", "(", class(legend_ncol), ")", ": ", legend_ncol, "\n", sep = "")
  cat("custom_order", "(", class(custom_order), ")", ": ", custom_order, "\n", sep = "")
  
  # 提取画布信息
  # file_width <- as.numeric(body$canvas$file_width)
  # file_height <- as.numeric(body$canvas$file_height)
  # cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  # cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  
  # 提取导出信息
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
  
  
  # 处理 color_scheme
  # 检查 color_scheme 是否需要设置为 NULL
  if (!is.null(color_scheme) && (all(color_scheme == "") || all(grepl("^\\s*$", color_scheme)))) {
    color_scheme <- NULL
    
  } else {
    color_scheme = parse_input_vector(color_scheme)
    cat("经过处理后的 color_scheme: ")
  }
  print(color_scheme)
  
  
  # 处理 label_is （转换成逻辑值）
  if(label_is == "FALSE") {
    label_is = FALSE
  } else {
    label_is = TRUE
  }
  cat("经过处理后的 label_is", "(", class(label_is), ")", ": ", label_is, "\n", sep = "")
  
  
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
  
  # ----------------------------------------------------------------------------
  
  
  
  ##执行函数
  
  # 数据分析
  data = pca(
    otu = otu,                          # otu 表格
    metadata = metadata,                # metadata 表格
    id_col = 1,                         # The OTU_ID column is in which column.
    group = group,                      # group
    parallel_method = parallel_method   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
  )
  cat("pca()：运行成功!", "\n")
  

  
  # 绘制图形
  p = pca_plot(
    data = data,  # 绘图数据
    color_scheme = color_scheme,  # 配色方案
    # group = "group",  # 分组信息
    custom_order = custom_order,  # 自定义图例排序
    seed = 123,  # 设置种子
    
    # 图形外观
    size_point = size_point,  # 点大小
    size_point_legend = size_point_legend,  # 图例点大小
    spacing_legend_point = spacing_legend_point,  # 图例内部间距
    spacing_legend_title = spacing_legend_title,  # 图例标题与正文的间距
    legend_ncol = legend_ncol,  # 图例列数
    label_is = label_is,        # 是否显示数据标签
    size_label = size_label,    # 标签大小
    label_font_color = NULL,    # 标签字体颜色，默认使用分组颜色
    
    # 标题设置
    title = title,                # 大标题
    title_sub = title_sub,        # 副标题
    title_legend = title_legend,  # 图例标题
    
    # 字号设置
    size_title = size_title,          # 大标题字号
    size_title_sub = size_title_sub,  # 副标题字号
    size_title_x = size_title_x,      # 横坐标标题字号
    size_title_y = size_title_y,      # 纵坐标标题字号
    size_title_legend = size_title_legend,  # 图例标题字号
    
    size_x = size_x,            # 横坐标刻度字符字号
    size_y = size_y,            # 纵坐标刻度字符字号
    size_legend = size_legend,  # 图例正文字号
    
    # 保存文件
    filename = filename,       # 保存文件名
    file_width = file_width,   # 图像宽度
    file_height = file_height  # 图像高度
  )
  # print(p)  # 预览结果
  
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

