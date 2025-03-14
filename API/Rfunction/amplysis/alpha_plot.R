# 如果没有安装必要的包，则先安装
required_packages <- c("ggplot2")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

# 加载 R 包
library(ggplot2)


##
# 盒线图
box_plot <- function(
    data,                # 绘图数据
    index_type,          # 指数类型
    x,                   # X 轴
    y,                   # Y 轴
    
    color_scheme,        # 配色方案
    # custom_order,        # 自定义图例排序
    
    # 图形外观
    size_point,          # 点大小
    size_differ,         # 显著性标记大小
    errorbar_width,      # 误差线上下横线的宽度
    errorbar_linewidth,  # 误差线竖线的宽度
    
    # 标题设置
    title,               # 大标题
    title_x,             # x 轴标题
    title_y,             # y 轴标题
    
    # 字号设置
    size_title,          # 大标题字号
    size_title_x,        # 横坐标标题字号
    size_title_y,        # 纵坐标标题字号
    
    size_x,              # 横坐标刻度字符字号
    size_y,              # 纵坐标刻度字符字号
    
    # 保存文件
    filename,            # 保存文件名
    file_width,          # 图像宽度
    file_height          # 图像高度
) {
  
  # 转换成符号
  group <- rlang::sym("group")
  differ_y = rlang::sym("differ_y")
  differ = rlang::sym("differ")
  
  p1 <- 
    ggplot2::ggplot(
      data, 
      ggplot2::aes(x = x, y = y)) + 
    
    #主题设置
    ggplot2::theme_bw() +
    
    # 图形设置
    # 添加误差线
    ggplot2::stat_boxplot(
      geom = "errorbar", 
      # 宽度和大小
      width = errorbar_width, linewidth = errorbar_linewidth,  
      ggplot2::aes(color = factor(x))) + # 颜色
    
    # 盒线图
    ggplot2::geom_boxplot(
      ggplot2::aes(color = x),    # 设置边框 color 和填充 fill 颜色为 gp 变量
      outlier.colour = "red",     # 指定异常值的颜色，使得异常值在图中更容易识别
      outlier.size = size_point,  # 异常点大小
      outlier.alpha = 0,
      size = 1.1,                 # 指定箱线图的线条粗细
      fill = "transparent",       # 设置填充颜色为透明
      alpha = 1                   # 设置边框的透明度
    ) +
    
    # 设置抖动点
    ggplot2::geom_jitter(width = 0.2,             # 抖动点范围
                         size = size_point,       # 抖动点大小
                         ggplot2::aes(color = factor(x)),  # 抖动点颜色
                         alpha = 0.5) +           # 抖动点透明度
    
    # 显著性标记
    ggplot2::geom_text(data = data,   # data = data[[index_type]], 
                       ggplot2::aes(x = !!group, y = !!differ_y, color = !!group, label = !!differ), 
                       size = size_differ) + 
    
    # 设置大标题
    ggplot2::labs(title = title) +
    # X、Y 轴标题
    ggplot2::labs(x = title_x, y = title_y) + 
    
    # 统一 theme() 避免覆盖
    ggplot2::theme(
      # 大标题字号
      plot.title = ggplot2::element_text(
        face = "bold", 
        size = size_title, hjust = 0.5, 
        margin = ggplot2::margin(t = 0, r = 0, b = 30, l = 0, unit = "pt")
      ),
      
      # X 轴标题
      axis.title.x = ggplot2::element_text(
        # face = "bold", 
        size = size_title_x, 
        margin = ggplot2::margin(t = 20, r = 0, b = 0, l = 0, unit = "pt")
      ),
      
      # Y 轴标题
      axis.title.y = ggplot2::element_text(
        # face = "bold", 
        size = size_title_y, angle = 90, 
        margin = ggplot2::margin(t = 0, r = 20, b = 0, l = 0, unit = "pt")
      ),
      
      # 刻度字号设置
      # 修改 x 轴刻度标签文本
      axis.text.x = ggplot2::element_text(
        face = "bold", 
        size = size_x, 
        margin = ggplot2::margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")
        ),   
      # 修改 y 轴刻度标签文本
      axis.text.y = ggplot2::element_text(
        size = size_y, 
        margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0, unit = "pt")
        ),  
      
      # 去除图例
      legend.position = "none", 
      
      
      # 图形边距
      plot.margin = ggplot2::margin(
        t = 50, r = 120, b = 50, l = 50, unit = "pt"
      )
    )
  
  ## 配色方案
  if(!is.null(color_scheme)) {
    # 应用自定义配色方案
    p1 <- p1 +
      ggplot2::scale_color_manual(values = color_scheme) +
      ggplot2::scale_fill_manual(values = color_scheme)
  }
  
  
  # 保证不会超出画布
  p1 <- p1 +
    ggplot2::coord_cartesian(clip = "off") 
  
  
  
  # ## 保存文件
  # # 定义文件名和文件夹路径
  # folder_path <- "relust"  # 文件夹路径
  # 
  # # 检查 "结果文件" 文件夹是否存在，若不存在则创建
  # if (!dir.exists(folder_path)) {
  #   dir.create(folder_path)
  # }
  
  
  # ##
  # # 检查 "PNG" 文件夹是否存在，若不存在则创建
  # png_folder_path <- file.path(folder_path, "PNG")
  # if (!dir.exists(png_folder_path)) {
  #   dir.create(png_folder_path)
  # }
  
  # # 保存为 PNG 文件
  # png_file_path <- file.path(getwd(), folder_path, paste0(filename, ".png"))
  # ggplot2::ggsave(filename = png_file_path, plot = p1, 
  #                 width = file_width, height = file_height, dpi = 300)
  # 
  # 
  # ##
  # # 检查 "PDF" 文件夹是否存在，若不存在则创建
  # pdf_folder_path <- file.path(folder_path, "PDF")
  # if (!dir.exists(pdf_folder_path)) {
  #   dir.create(pdf_folder_path)
  # }
  # 
  # # 保存为 PDF 文件
  # pdf_file_path <- file.path(getwd(), pdf_folder_path, paste0(filename, ".pdf"))
  # ggplot2::ggsave(filename = pdf_file_path, plot = p1, 
  #                 width = file_width, height = file_height, dpi = 300)
  
  
  ##
  return(p1)
}


# box_plot(data = data, index_type = "Shannon", x = data[[index_type]][, "group"], 
#          y = data[[index_type]][, 1], color_scheme = NULL, 
#          size_point = 5, size_differ = 14, errorbar_width = 0.15, 
#          errorbar_linewidth = 0.8, title_x = NULL, title_y = NULL, 
#          size_title = 40, size_title_x = 28, size_title_y = 28, size_x = 28, 
#          size_y = 28, filename = "alpha", file_width = 12, file_height = 9)




##
# 盒线图
alpha_plot <- function(
    data,                    # 绘图数据
    color_scheme = NULL,     # 配色方案
    custom_order = NULL,     # 自定义图例排序
    
    # 图形外观
    size_point = 5,            # 点大小
    size_differ = 18,          # 显著性标记大小
    errorbar_width = 0.15,     # 误差线上下横线的宽度
    errorbar_linewidth = 0.8,  # 误差线竖线的宽度
    
    # 标题设置
    # title = NULL,             # 大标题
    title_x = NULL,           # x 轴标题
    title_y = NULL,           # y 轴标题
    
    # 字号设置
    size_title = 48,          # 大标题字号
    size_title_x = 32,        # 横坐标标题字号
    size_title_y = 32,        # 纵坐标标题字号
    
    size_x = 32,              # 横坐标刻度字符字号
    size_y = 32,              # 纵坐标刻度字符字号
    
    # 保存文件
    filename = "alpha",       # 保存文件名
    file_width = 12,          # 图像宽度
    file_height = 9           # 图像高度
    
) {
  ## 自定义顺序
  customOrder <- function(data,  # 数据
                          col,   # 输入列名。要讲数据中的哪一列转换成因子类型
                          custom_order  # 自定义顺序
  ){
    # 将 group 列转换为因子类型并按照自定义顺序排序
    data[, col] <- factor(data[, col], levels = custom_order)
    data <- dplyr::arrange(data, col)
    return(data)
  }
  
  # 自定义横坐标顺序
  if(!is.null(custom_order)) {
    # 设置分组信息
    group = "group"
    
    # 自定义顺序
    for (i in 1:length(data)) {
      data[[i]] = customOrder(data[[i]], group, custom_order)
    }
    cat("Custom legend order: ", custom_order, "\n", sep = " ")
  }
  
  # 保存结果的列表
  result <- list()
  
  title = NULL
  # 设置标题
  if(is.null(title)) {
    title = tools::toTitleCase(names(data))
  }
  # 将 PD 转换为大写
  title <- gsub("pd", "PD", title, ignore.case = TRUE)
  
  # 设置返回结果命名
  result_name = names(data)
  
  # 绘制图形
  for(i in 1:length(data)) {
    # 参数设置
    title1 = title[i]    # 绘图标题
    x = data[[i]][, "group"]  # x 轴
    y = data[[i]][, 1]        # y 轴
    filename1 = NULL
    filename1 = paste0(filename, "_", names(data)[i])  # 文件名
    
    # 绘图
    p1 <- box_plot(data = data[[i]], index_type = 1, x = x, y = y, 
                   color_scheme = color_scheme, 
                   
                   size_point = size_point, size_differ = size_differ, errorbar_width = errorbar_width, 
                   errorbar_linewidth = errorbar_linewidth,
                   
                   title = title1, title_x = title_x, title_y = title_y,
                   
                   size_title = size_title, size_title_x = size_title_x, size_title_y = size_title_y, 
                   size_x = size_x, size_y = size_y,  
                   
                   filename = filename1, file_width = file_width, file_height = file_height)
    
    # 将图形保存到结果列表中
    result[[result_name[i]]] <- p1
    
    print(p1) # 预览结果
  }
  
  
  ##
  cat("\033[32mtaxa_bar: success!\033[0m\n")
  cat("\033[0;32m", "The file has been saved to \n",
      getwd(), "/result\033[0m\n", sep = "")
  
  return(result)
}


