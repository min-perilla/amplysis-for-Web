# 物种堆叠图

source("./Rfunction/amplysis/taxa_bar.R")       # 分析函数
source("./Rfunction/amplysis/taxa_bar_plot.R")  # 绘图函数
source("./Rfunction/amplysis/parse_input_vector.R")  # 将字符转换为向量

# source("./amplysis/taxa_bar.R")       # 分析函数
# source("./amplysis/taxa_bar_plot.R")  # 绘图函数
# source("./amplysis/parse_input_vector.R")  # 将字符转换为向量

# ------------------------------------------------------------------------------
api_taxa_bar_plot <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  ##
  # 提取参数并赋值给变量
  isFullAnalysis <- body$isFullAnalysis
  data <- body$species_stack_data        # 绘图数据
  
  cat("全量分析", "(", class(isFullAnalysis), ")", "：", isFullAnalysis, "\n", sep = "")
  cat("绘图数据类型：", class(data), "\n", sep = "")
  
  
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
  color_scheme <- body$colorSettings$color_scheme###########################
  cat("color_scheme", "(", class(color_scheme), ")", ": ", color_scheme, "\n", sep = "")
  
  # 提取大标题参数
  title <- body$title$title
  size_title <- as.numeric(body$title$size_title)
  cat("title", "(", class(title), ")", ": ", title, "\n", sep = "")
  cat("size_title", "(", class(size_title), ")", ": ", size_title, "\n", sep = "")
  
  # 提取图表参数
  bar_type <- body$chart$bar_type
  bar_width <- as.numeric(body$chart$bar_width)
  grid_line <- body$chart$grid_line
  cat("bar_type", "(", class(bar_type), ")", ": ", bar_type, "\n", sep = "")
  cat("bar_width", "(", class(bar_width), ")", ": ", bar_width, "\n", sep = "")
  cat("grid_line", "(", class(grid_line), ")", ": ", grid_line, "\n", sep = "")
  
  # 提取 X 轴参数
  title_x <- body$xAxis$title_x
  size_title_x <- as.numeric(body$xAxis$size_title_x)
  size_x <- as.numeric(body$xAxis$size_x)
  custom_order <- body$xAxis$custom_order
  cat("title_x", "(", class(title_x), ")", ": ", title_x, "\n", sep = "")
  cat("size_title_x", "(", class(size_title_x), ")", ": ", size_title_x, "\n", sep = "")
  cat("size_x", "(", class(size_x), ")", ": ", size_x, "\n", sep = "")
  cat("custom_order", "(", class(custom_order), ")", ": ", custom_order, "\n", sep = "")
  
  # 提取 Y 轴参数
  title_y <- body$yAxis$title_y
  size_title_y <- as.numeric(body$yAxis$size_title_y)
  size_y <- as.numeric(body$yAxis$size_y)
  cat("title_y", "(", class(title_y), ")", ": ", title_y, "\n", sep = "")
  cat("size_title_y", "(", class(size_title_y), ")", ": ", size_title_y, "\n", sep = "")
  cat("size_y", "(", class(size_y), ")", ": ", size_y, "\n", sep = "")
  
  # 提取分面图参数
  size_title_facet <- as.numeric(body$facet$size_title_facet)
  color_bg_facet <- body$facet$color_bg_facet
  custom_order_F <- body$facet$custom_order_F
  cat("size_title_facet", "(", class(size_title_facet), ")", ": ", size_title_facet, "\n", sep = "")
  cat("color_bg_facet", "(", class(color_bg_facet), ")", ": ", color_bg_facet, "\n", sep = "")
  cat("custom_order_F", "(", class(custom_order_F), ")", ": ", custom_order_F, "\n", sep = "")
  
  # 提取图例参数
  title_legend <- body$legend$title_legend
  size_title_legned <- as.numeric(body$legend$size_title_legned)
  size_legned <- as.numeric(body$legend$size_legned)
  size_point_legend <- as.numeric(body$legend$size_point_legend)
  spacing_legend_title <- as.numeric(body$legend$spacing_legend_title)
  spacing_legend_point <- as.numeric(body$legend$spacing_legend_point)
  legend_ncol <- as.numeric(body$legend$legend_ncol)
  cat("title_legend", "(", class(title_legend), ")", ": ", title_legend, "\n", sep = "")
  cat("size_title_legned", "(", class(size_title_legned), ")", ": ", size_title_legned, "\n", sep = "")
  cat("size_legned", "(", class(size_legned), ")", ": ", size_legned, "\n", sep = "")
  cat("size_point_legend", "(", class(size_point_legend), ")", ": ", size_point_legend, "\n", sep = "")
  cat("spacing_legend_title", "(", class(spacing_legend_title), ")", ": ", spacing_legend_title, "\n", sep = "")
  cat("spacing_legend_point", "(", class(spacing_legend_point), ")", ": ", spacing_legend_point, "\n", sep = "")
  cat("legend_ncol", "(", class(legend_ncol), ")", ": ", legend_ncol, "\n", sep = "")
  
  # # 提取画布参数
  # file_width <- as.numeric(body$canvas$file_width)
  # file_height <- as.numeric(body$canvas$file_height)
  # cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  # cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  
  # 提取导出参数
  filename <- body$exportSettings$filename
  file_width <- as.numeric(body$exportSettings$file_width)
  file_height <- as.numeric(body$exportSettings$file_height)
  formats <- body$exportSettings$formats
  cat("filename", "(", class(filename), ")", ": ", filename, "\n", sep = "")
  cat("file_width", "(", class(file_width), ")", ": ", file_width, "\n", sep = "")
  cat("file_height", "(", class(file_height), ")", ": ", file_height, "\n", sep = "")
  cat("formats", "(", class(formats), ")", ": ", paste(formats, collapse = ", "), "\n", sep = "")
  
  
  
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
  if(group2 == "NULL") {
    group2 = NULL
  }
  
  # 处理标题 title
  if(title == "NULL") {
    title = NULL
  }
  
  # 处理 color_scheme
  color_scheme = parse_input_vector(color_scheme)
  cat("经过处理后的 color_scheme: ")
  print(color_scheme)
  
  
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
  
  
  # 处理 custom_order_F
  # 如果 custom_order_F 非 NULL，但为空字符串，或仅包含空格、换行符等，则将其设置为 NULL
  if (!is.null(custom_order_F) && (all(custom_order_F == "") || all(grepl("^\\s*$", custom_order_F)))) {
    custom_order_F <- NULL
  }
  
  # 提取字符
  custom_order_F = parse_input_vector(custom_order_F)
  cat("经过处理后的 custom_order_F: ")
  print(custom_order_F)
  cat("\n")
  
  # 处理 grid_line （转换成逻辑值）
  if(grid_line == "FALSE") {
    grid_line = FALSE
  } else {
    grid_line = TRUE
  }
  
  
  
  # ----------------------------------------------------------------------------
  ##执行函数
  
  ## 检查是否执行全量分析
  # 执行全量分析
  # if(isTRUE(isFullAnalysis)) {
  #   cat("执行全量分析。\n")
  
  # 数据分析
  data = taxa_bar(
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
  cat("taxa_bar()：运行成功!", "\n")
  
  
  # 绘制图形
  p = taxa_bar_plot(
    data = data,
    color_scheme = color_scheme,  # 配色方案
    tax_cla = tax_cla,            # 分类等级
    x_group = group1,             # 分组1
    facet_group = group2,         # 分组2
    y_abun = "abun",              # Y 轴数据
    
    
    # custom_order = c("AA", "AB", "AR", "AD",
    #                  "BA", "BB", "BR", "BD", 
    #                  "RA", "RB", "RR", "RD",
    #                  "DA", "DB", "DR", "DD"),
    # custom_order_F = c("A", "B", "R", "D"),
    
    custom_order = custom_order,      # 自定义横坐标排序
    custom_order_F = custom_order_F,  # 自定义分面图排序
    
    
    # 图形外观
    bar_type = bar_type,
    bar_width = bar_width,
    grid_line = grid_line,
    size_point_legend = size_point_legend,        # 图例点大小
    spacing_legend_point = spacing_legend_point,  # 图例内部间距
    spacing_legend_title = spacing_legend_title,  # 图例标题与正文的间距
    
    # title = "Species Stacked Plot",
    title = title,
    title_x = title_x,
    # title_legend = "Enrichment Culture \nTop 8 Phyla",
    title_legend = title_legend,
    
    # 字号设置
    size_title = size_title,                # 大标题字号
    size_title_legned = size_title_legned,  # 图例标题字号
    size_legned = size_legned,              # 图例正文字号
    size_title_x = size_title_x,            # 横坐标标题字号
    size_x = size_x,                        # 横坐标刻度字符字号
    size_title_y = size_title_y,            # 纵坐标标题字号
    size_y = size_y,                        # 纵坐标刻度字符字号
    size_title_facet = size_title_facet,    # 分面图标题字号
    
    legend_ncol = legend_ncol,
    filename = filename,
    file_width = file_width,
    file_height = file_height
  )
  
  
  
  # } else {
  #   # 只执行绘图函数
  #   cat("只执行绘图函数。\n")
  #   
  #   # 绘制图形
  #   p = taxa_bar_plot(
  #     data = data,
  #     color_scheme = color_scheme,  # 配色方案
  #     tax_cla = tax_cla,            # 分类等级
  #     x_group = group1,             # 分组1
  #     facet_group = group2,         # 分组2
  #     y_abun = "abun",              # Y 轴数据
  #     
  #     
  #     # custom_order = c("AA", "AB", "AR", "AD",
  #     #                  "BA", "BB", "BR", "BD", 
  #     #                  "RA", "RB", "RR", "RD",
  #     #                  "DA", "DB", "DR", "DD"),
  #     # custom_order_F = c("A", "B", "R", "D"),
  #     
  #     custom_order = custom_order,      # 自定义横坐标排序
  #     custom_order_F = custom_order_F,  # 自定义分面图排序
  #     
  #     
  #     # 图形外观
  #     bar_type = bar_type,
  #     bar_width = bar_width,
  #     grid_line = grid_line,
  #     size_point_legend = size_point_legend,        # 图例点大小
  #     spacing_legend_point = spacing_legend_point,  # 图例内部间距
  #     spacing_legend_title = spacing_legend_title,  # 图例标题与正文的间距
  #     
  #     # title = "Species Stacked Plot",
  #     title = title,
  #     title_x = title_x,
  #     # title_legend = "Enrichment Culture \nTop 8 Phyla",
  #     title_legend = title_legend,
  #     
  #     # 字号设置
  #     size_title = size_title,                # 大标题字号
  #     size_title_legned = size_title_legned,  # 图例标题字号
  #     size_legned = size_legned,              # 图例正文字号
  #     size_title_x = size_title_x,            # 横坐标标题字号
  #     size_x = size_x,                        # 横坐标刻度字符字号
  #     size_title_y = size_title_y,            # 纵坐标标题字号
  #     size_y = size_y,                        # 纵坐标刻度字符字号
  #     size_title_facet = size_title_facet,    # 分面图标题字号
  #     
  #     legend_ncol = legend_ncol,
  #     filename = legend_ncol,
  #     file_width = file_width,
  #     file_height = file_height
  #   )
  # }
  
  
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

