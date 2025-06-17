# 箱线图
source("./Rfunction/amplysis/alpha.R")       # 分析函数
source("./Rfunction/amplysis/alpha_plot.R")  # 绘图函数
source("./Rfunction/amplysis/process_metadata.R")  # 处理 metadata 函数


# ------------------------------------------------------------------------------
api_alpha_plot <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)

  # 提取 OTU 和 Metadata 数据
  otu <- body$featureData
  metadata <- body$metadata
  tree <- body$tree

  cat("OTU table Type: ", class(otu), "\n", sep = "")
  cat("metadata file Type: ", class(metadata), "\n", sep = "")
  cat("tree file Type: ", class(tree), "\n", sep = "")


  ##
  if (is.null(tree) || !nzchar(tree)) {
    cat("Warning: tree 为空，跳过 read.tree()\n")
    tree <- NULL  # 设为空，后续代码可以检测并跳过
  } else {
    tree <- read.tree(text = tree)
    cat("tree 已成功转换为 phylo 对象\n")
  }


  # 检查树的结构，确保它是一个有效的 phylo 对象
  cat("树的结构:\n")
  str(tree)

  # 检查 edge.length 是否存在，并输出前几个元素
  if ("edge.length" %in% names(tree)) {
    cat("边长（edge.length）:\n")
    print(head(tree$edge.length))
  } else {
    cat("树没有边长（edge.length）。\n")
    tree = NULL
  }








  cat("\n前端传入的参数：", "\n", sep = "")
  # 提取分组参数
  group <- body$groupInformation$group
  cat("group", "(", class(group), ")", ": ", group, "\n", sep = "")

  # 提取平行样参数
  replicateInformation <- body$replicate$information
  replicate_method <- body$replicate$replicate_method
  cat("replicateInformation", "(", class(replicateInformation), ")", ": ", replicateInformation, "\n", sep = "")
  cat("replicate_method", "(", class(replicate_method), ")", ": ", replicate_method, "\n", sep = "")

  # 提取颜色信息
  color_scheme <- body$color$color_scheme
  cat("color_scheme", "(", class(color_scheme), ")", ": ", color_scheme, "\n", sep = "")

  # 提取统计分析方法
  method <- body$methods$comparisons
  cat("method", "(", class(method), ")", ": ", method, "\n", sep = "")

  # 提取大标题信息
  # title <- body$attributes$title$name
  size_title <- as.numeric(body$attributes$title$size)
  # cat("title", "(", class(title), ")", ": ", title, "\n", sep = "")
  cat("size_title", "(", class(size_title), ")", ": ", size_title, "\n", sep = "")

  # 提取图形属性
  size_point <- as.numeric(body$attributes$plot$size_point)
  size_differ <- as.numeric(body$attributes$plot$size_differ)
  cat("size_point", "(", class(size_point), ")", ": ", size_point, "\n", sep = "")
  cat("size_differ", "(", class(size_differ), ")", ": ", size_differ, "\n", sep = "")

  # 提取误差线属性
  errorbar_width <- as.numeric(body$attributes$errorbar$width)
  errorbar_linewidth <- as.numeric(body$attributes$errorbar$line_width)
  cat("errorbar_width", "(", class(errorbar_width), ")", ": ", errorbar_width, "\n", sep = "")
  cat("errorbar_linewidth", "(", class(errorbar_linewidth), ")", ": ", errorbar_linewidth, "\n", sep = "")

  # 提取 X 轴信息
  title_x <- body$axis$x$title
  size_title_x <- as.numeric(body$axis$x$title_size)
  size_x <- as.numeric(body$axis$x$tick_size)
  cat("title_x", "(", class(title_x), ")", ": ", title_x, "\n", sep = "")
  cat("size_title_x", "(", class(size_title_x), ")", ": ", size_title_x, "\n", sep = "")
  cat("size_x", "(", class(size_x), ")", ": ", size_x, "\n", sep = "")

  # 提取 X 轴自定义排序
  custom_order <- body$axis$x_order$custom_order
  cat("custom_order", "(", class(custom_order), ")", ": ", custom_order, "\n", sep = "")

  # 提取 Y 轴信息
  title_y <- body$axis$y$title
  size_title_y <- as.numeric(body$axis$y$title_size)
  size_y <- as.numeric(body$axis$y$tick_size)
  cat("title_y", "(", class(title_y), ")", ": ", title_y, "\n", sep = "")
  cat("size_title_y", "(", class(size_title_y), ")", ": ", size_title_y, "\n", sep = "")
  cat("size_y", "(", class(size_y), ")", ": ", size_y, "\n", sep = "")

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


  # 系统发育树处理
  if(is.null(tree)) {
    cat("\n系统发育树文件为空，不启用 PD 指数分析", "\n\n", sep = "")
  } else {
    cat("\n检测到系统发育树文件，启用 PD 指数分析", "\n\n", sep = "")
  }


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
  data = alpha(
    otu = otu,                           # otu 表格
    metadata = metadata,                 # metadata 表格
    id_col = 1,                          # The OTU_ID column is in which column.
    group = group,                       # group
    replicate_method = replicate_method,   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
    tree = tree,                         # tree file
    method = method)
    # method 对应的方法：
    #            1 Tukey-Hsd
    #            2 Fisher-LSD
    #            3 S-N-K, Student-Newman-Keuls
    #            4 Duncan(new)
    #            5 Scheffe
    #            6 Waller-Duncan
    #            7 REGW
  cat("alpha()：运行成功!", "\n")


  ##
  # 绘制图形
  p = alpha_plot(
    data = data,                  # 绘图数据
    color_scheme = color_scheme,  # 配色方案
    custom_order = custom_order,  # 自定义图例排序

    # 图形外观
    size_point = size_point,      # 点大小
    size_differ = size_differ,    # 显著性标记大小
    errorbar_width = errorbar_width,  # 误差线上下横线的宽度
    errorbar_linewidth = errorbar_linewidth,  # 误差线竖线的宽度

    # 标题设置
    # title = NULL,              # 大标题
    title_x = title_x,           # x 轴标题
    title_y = title_y,           # y 轴标题

    # 字号设置
    size_title = size_title,     # 大标题字号
    size_title_x = size_title_x, # 横坐标标题字号
    size_title_y = size_title_y, # 纵坐标标题字号

    size_x = size_x,             # 横坐标刻度字符字号
    size_y = size_y,             # 纵坐标刻度字符字号

    # 保存文件
    filename = "alpha",          # 保存文件名
    file_width = file_width,     # 图像宽度
    file_height = file_height    # 图像高度
  )
  # print(p)  # 预览结果


  ## 返回 SVG 数据到前端
  svg_list <- list()

  for (plot_name in names(p)) {
    svg_output <- svglite::svgstring(
      width = file_width, height = file_height, standalone = TRUE)  # 开启 SVG 设备
    print(p[[plot_name]])  # 绘制单个 ggplot 对象
    if (dev.cur() > 1) dev.off()  # 关闭图形设备

    # 存入 list
    svg_list[[plot_name]] <- as.character(svg_output())
  }

  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    otu = 1,      # 1 表示 OTU 不为空
    metadata = 1, # 1 表示 metadata 不为空

    data_plot = data,  # 绘图数据
    svg = svg_list     # 7 张 SVG 图像
  ))
}

