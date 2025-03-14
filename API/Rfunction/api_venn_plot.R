# Venn 图

source("./Rfunction/amplysis/venn.R")       # 分析函数
source("./Rfunction/amplysis/venn_plot.R")  # 绘图函数
source("./Rfunction/amplysis/process_metadata.R")  # 处理 metadata 函数


# ------------------------------------------------------------------------------
api_venn_plot <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  ##
  # 提取参数并赋值给变量
  # isFullAnalysis <- body$isFullAnalysis
  # data <- body$species_stack_data        # 绘图数据
  
  # cat("全量分析", "(", class(isFullAnalysis), ")", "：", isFullAnalysis, "\n", sep = "")
  # cat("绘图数据类型：", class(data), "\n", sep = "")
  
  
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
  color_scheme <- body$colorSettings$color_scheme
  cat("color_scheme", "(", class(color_scheme), ")", ": ", color_scheme, "\n", sep = "")
  
  # 提取显示百分比相关参数
  show_percentage <- body$percentage$show_percentage
  digits <- as.numeric(body$percentage$digits)
  cat("show_percentage", "(", class(show_percentage), ")", ": ", show_percentage, "\n", sep = "")
  cat("digits", "(", class(digits), ")", ": ", digits, "\n", sep = "")
  
  # 提取字号相关参数
  size_set_name <- as.numeric(body$size$size_set_name)       # 数据集标题字体字号
  size_text <- as.numeric(body$size$size_text)
  cat("size_set_name", "(", class(size_set_name), ")", ": ", size_set_name, "\n", sep = "")
  cat("size_text", "(", class(size_text), ")", ": ", size_text, "\n", sep = "")
  

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


  # 处理 color_scheme
  # 检查 color_scheme 是否需要设置为 NULL
  if (!is.null(color_scheme) && (all(color_scheme == "") || all(grepl("^\\s*$", color_scheme)))) {
    color_scheme <- NULL
    
  } else {
    color_scheme = parse_input_vector(color_scheme)
    cat("经过处理后的 color_scheme: ")
  }
  print(color_scheme)
  
  
  # 处理 show_percentage （转换成逻辑值）
  if(show_percentage == "FALSE") {
    show_percentage = FALSE
  } else {
    show_percentage = TRUE
  }
  cat("经过处理后的 show_percentage", "(", class(show_percentage), ")", ": ", show_percentage, "\n", sep = "")
  # ----------------------------------------------------------------------------
  
  
  
  # 检查 metadata 数据框，如果发现分组不在 2 到 4 之间，就 return
  # 少于 2 个分组，return(-2)
  # 多出 4 个分组，return(-4)
  # 定义函数，检查 metadata 数据框中的分组数量
  
  
  # 检查指定的分组列是否存在
  if (!group %in% colnames(metadata)) {
    stop("The specified group column does not exist in the metadata.")
  }
  
  # 提取分组列的值，并去重（排除 NA）
  unique_groups <- unique(metadata[[group]])
  unique_groups <- unique_groups[!is.na(unique_groups)]
  
  # 统计唯一分组的数量
  num_groups <- length(unique_groups)
  
  # 检查分组数量是否符合要求并打印信息
  if(num_groups < 2) {
    cat("分组数量少于2。\n")

    return(list(metadata = -2))
    
  } else if(num_groups > 4) {
    cat("分组数量超过4。\n")

    return(list(metadata = -4))
  }
  
  
  
  
  
  
  ##执行函数

  # 数据分析
  data = venn(
    otu = otu,                          # otu 表格
    metadata = metadata,                # metadata 表格
    id_col = 1,                         # The OTU_ID column is in which column.
    group = group,                      # group
    parallel_method = parallel_method   # 平行样处理方法，默认 mean（平均）。可选：mean（平均）、sum（求和）、median（中位数）
  )
  cat("venn()：运行成功!", "\n")
  
  
  # 转换为数据框
  data = as.data.frame(data)
  
  
  
  # 绘制图形
  p = venn_plot(
    data = data,  # 绘图数据
    color_scheme = color_scheme,  # 配色方案
    
    # 图形外观
    show_percentage = show_percentage,  # 显示百分比
    digits = digits,           # 更改百分比保留小数
    
    # 字号设置
    size_set_name = size_set_name,  # 各数据集标题大小
    size_text = size_text,     # 图内字体大小
    
    # 保存文件
    filename = NULL,           # 保存文件名
    file_width = file_width,   # 图像宽度
    file_height = file_height  # 图像高度
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

