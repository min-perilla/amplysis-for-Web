# 如果没有安装必要的包，则先安装
required_packages <- c("ggplot2", "tibble", "ggrepel")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(ggplot2)
library(tibble)     # rownames_to_column
library(ggrepel)    # 添加自适应数据标签

#
CCA_plot = function(
    data,                    # 绘图数据
    color_scheme = NULL,     # 配色方案
    # group = "group",         # 分组信息
    custom_order = NULL,     # 自定义图例排序
    seed = 123,              # 种子
    
    # 图形外观
    size_point = 4.5,        # 点大小
    size_point_legend = 8,   # 图例点大小
    spacing_legend_point = 1.2,  # 图例内部间距
    spacing_legend_title = 0.5,  # 图例标题与正文的间距
    legend_ncol = 1,         # 图例列数
    label_is = T,            # 是否显示数据标签
    size_label = 5,          # 标签大小
    label_font_color = NULL, # 标签字体颜色，默认使用分组颜色
    ellipse_type = "t",  # 置信椭圆的计算方法，可选三种：
    # "t"（默认）：基于 t 分布计算椭圆，适用于小样本，使用稳健估计（MASS::cov.trob()）。
    # "norm"：基于正态分布计算椭圆，使用协方差矩阵估计，不使用稳健估计。
    # "euclid"：基于欧几里得距离绘制固定半径的圆，与数据尺度相关。
    
    # 标题设置
    title = NULL,            # 大标题
    title_sub = NULL,        # 副标题
    title_legend = "Group",  # 图例标题
    
    # 字号设置
    size_title = 28,         # 大标题字号
    size_title_sub = 16,     # 副标题字号
    size_title_x = 20,       # 横坐标标题字号
    size_title_y = 20,       # 纵坐标标题字号
    size_title_legend = 24,  # 图例标题字号
    
    size_x = 16,             # 横坐标刻度字符字号
    size_y = 16,             # 纵坐标刻度字符字号
    size_legend = 16,        # 图例正文字号
    
    # 保存文件
    filename = "CCA",        # 保存文件名
    file_width = 12,         # 图像宽度
    file_height = 9          # 图像高度
) 
{
  # 种子设置
  set.seed(seed = seed)
  
  group = "group"    # 分组信息
  
  # 判断是否显示数据标签
  if(isTRUE(label_is)) {
    labelNum = 200
  }else{
    labelNum = 0
  }
  
  # 自定义图例排序
  if(!is.null(custom_order)){
    data[["data"]][[group]] <- factor(data[["data"]][[group]], levels = custom_order)
    data[["data"]] <- dplyr::arrange(data[["data"]], group)
    
    cat("Custom legend order: ", custom_order, "\n",sep = "")
  }
  
  
  # ----------------------------------------------------------------------------
  ## 置信椭圆计算方法
  # 置信椭圆的三种计算方法
  ellipse_methods <- c("t", "norm", "euclid")
  
  # 计算方法对应的描述
  ellipse_descriptions <- list(
    "t" = "基于 t 分布计算椭圆，适用于小样本，使用稳健估计",
    "norm" = "基于正态分布计算椭圆，使用协方差矩阵估计，不使用稳健估计",
    "euclid" = "基于欧几里得距离绘制固定半径的圆，与数据尺度相关"
  )
  
  # 如果输入是数字，则通过取模计算对应的方法
  if (is.numeric(ellipse_type)) {
    index <- (ellipse_type - 1) %% length(ellipse_methods) + 1
    ellipse_type <- ellipse_methods[index]
  }
  
  # 如果输入不是有效的方法，默认使用 "t"
  if (!(ellipse_type %in% ellipse_methods)) {
    ellipse_type <- "t"
  }
  
  # 输出当前选定的置信椭圆计算方法
  cat("\n置信椭圆的计算方法：ellipse_type = \"", ellipse_type, "\" ",
      "(", ellipse_descriptions[[ellipse_type]], ")\n", sep = "")
  
  # 输出其他可选方法（排除当前选中的方法）
  remaining_methods <- setdiff(ellipse_methods, ellipse_type)
  if (length(remaining_methods) > 0) {
    cat("其他可选方法（也可输入对应数字选择）：\n")
    for (method in ellipse_methods) {
      if (method != ellipse_type) {
        index <- which(ellipse_methods == method)
        cat(index, ":", method, "-", ellipse_descriptions[[method]], "\n")
      }
    }
  }
  cat("\n")
  # ----------------------------------------------------------------------------
  
  
  
  # x、y 轴
  x = "CCA1"
  y = "CCA2"
  
  
  # 获取CCA1和CCA2的贡献度百分比
  x_contrib <- data[[x]]
  y_contrib <- data[[y]]
  
  
  # 转换成符号对象
  group_sym <- rlang::sym(group)
  x_sym <- rlang::sym(x)
  y_sym <- rlang::sym(y)
  
  
  ## 绘图
  p1 <- ggplot2::ggplot(
    data = data[["data"]],     # 绘图数据
    ggplot2::aes(
      x = !!x_sym,   # x 轴
      y = !!y_sym,   # y 轴
      color = !!group_sym)) + 
    
    ##
    # 主题配色设置
    ggplot2::theme_bw() +  # 白色背景和黑色线条
    
    #添加过原点的虚线
    ggplot2::geom_vline(xintercept = 0, lty = "dashed") +
    ggplot2::geom_hline(yintercept = 0, lty = "dashed") +
    
    #绘制点图并设定大小
    ggplot2::geom_point(size = size_point, shape = 16, alpha = 0.7) + 
    ggplot2::theme(panel.grid = ggplot2::element_blank())  # 去除网格线
  
  
  ## 添加自适应标签
  if (is.null(label_font_color)) {  # 标签字体默认配色
    p1 <- p1 + 
      ggrepel::geom_text_repel(
        ggplot2::aes(label = sample), size = size_label, 
        box.padding = ggplot2::unit(0.6, "lines"), 
        point.padding = ggplot2::unit(0.5, "lines"), 
        max.overlaps = labelNum, alpha = 0.8, show.legend = F, seed = seed) 
  } else {
    # 自定义标签颜色
    p1 <- p1 + 
      ggrepel::geom_text_repel(
        ggplot2::aes(label = sample), 
        
        color = label_font_color,  # 标签字体颜色 
        
        size = size_label, 
        box.padding = ggplot2::unit(0.6, "lines"), 
        point.padding = ggplot2::unit(0.5, "lines"), 
        max.overlaps = labelNum, alpha = 0.8, show.legend = F, seed = seed)
  }
  
  
  p1 <- p1 + 
    
    #将x、y轴标题改为贡献度
    ggplot2::labs(x = x_contrib,
                  y = y_contrib) + 
    
    #添加置信椭圆
    ggplot2::stat_ellipse(
      data = data[["data"]],
      geom = "polygon",
      level = 0.95,      # level：置信水平
      linetype = 2,      # 线型样式
      linewidth = 0.4,
      ggplot2::aes(fill = group),
      alpha = 0.15,
      show.legend = F,   # 图例不展示
      # type = "t"       # 默认，基于 t 分布的椭圆（适用于小样本，使用稳健估计 MASS::cov.trob()）
      # type = "norm"    # 基于正态分布的椭圆（使用协方差矩阵计算，不使用稳健估计）
      # type = "euclid"  # 以欧几里得距离绘制固定半径的圆（与数据尺度相关）
      type = ellipse_type  # 置信椭圆的计算方法
    ) + 
    
    
    #设置大标题
    ggplot2::labs(title = title) +
    # hjust 参数（取值范围 0 到 1）控制文本相对于其位置的水平对齐方式
    ggplot2::theme(plot.title = ggplot2::element_text(
      face = "bold", size = size_title, hjust = 0.5)) + 
    
    # 设置副标题
    ggplot2::labs(subtitle = title_sub) + 
    # 副标题字号
    ggplot2::theme(plot.subtitle = ggplot2::element_text(
      face = "bold", size = size_title_sub, hjust = 0)) +  # hjust参数（取值范围 0 到 1）控制文本相对于其位置的水平对齐方式
    
    # 刻度字号设置
    ggplot2::theme(axis.title.x = ggplot2::element_text(size = size_title_x),     # 修改X轴标题文本
                   axis.title.y = ggplot2::element_text(size = size_title_y, angle = 90),  # 修改y轴标题文本
                   axis.text.x = ggplot2::element_text(size = size_x),                     # 修改x轴刻度标签文本
                   axis.text.y = ggplot2::element_text(size = size_y)                      # 修改y轴刻度标签文本
    ) + 
    
    #设置图例
    ggplot2::guides(
      shape = "none", 
      color = ggplot2::guide_legend(
        title = title_legend,              # 设置图例标题
        ncol = legend_ncol,                # 图标列数
        override.aes = list(size = size_point_legend))) + 
    # 图例字号
    ggplot2::theme(legend.title = ggplot2::element_text(
      face = "bold", size = size_title_legend, color = "black")) + # 标题大小
    ggplot2::theme(legend.text = ggplot2::element_text(
      face = "bold", size = size_legend, color = "black")) +       # 字体、字号
    
    
    # 设置图例文本边距
    ggplot2::theme(legend.text = ggplot2::element_text(
      margin = ggplot2::margin(t = 5, r = 5, b = 5, l = 5, unit = "pt"))) +
    ggplot2::theme(legend.title = ggplot2::element_text(hjust = 0.5)) +                                 #图例标题居中
    
    
    # 图例内部间距
    ggplot2::theme(legend.key.height = ggplot2::unit(
      spacing_legend_point, "cm")) + 
    # 图例标题与正文的间距
    ggplot2::theme(legend.title = element_text(
      margin = ggplot2::margin(b = spacing_legend_title, unit = 'cm'))) + 
    
    
    #边距设置：t表示顶部边距，b表示底部边距，r表示右边距，l表示左边距
    #大标题边距
    ggplot2::theme(plot.title = ggplot2::element_text(
      margin = ggplot2::margin(t = 0, r = 0, b = 15, l = 0, unit = "pt"))) +
    #X轴边距
    ggplot2::theme(axis.title.x = ggplot2::element_text(
      margin = ggplot2::margin(t = 10, r = 0, b = 0, l = 0, unit = "pt"))) +
    #Y轴边距
    ggplot2::theme(axis.title.y = ggplot2::element_text(
      margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0, unit = "pt"))) +
    #图例边距
    ggplot2::theme(legend.margin = ggplot2::margin(
      t = 0, r = 0, b = 0, l = 20, unit = "pt")) +
    
    #调整这个图形的边距
    ggplot2::theme(plot.margin = ggplot2::margin(
      t = 20, r = 30, b = 20, l = 30, unit = "pt"))
  
  
  ##
  # 添加环境因子数据
  p1 <- p1 + 
    # 添加环境因子箭头
    ggplot2::geom_segment(
      data = data[["env"]],           # 绘图数据
      ggplot2::aes(x = 0,           # X 轴
                   y = 0,           # Y 轴
                   xend = data[["env"]][,1],   # X 轴结束的位置
                   yend = data[["env"]][,2]),  # Y 轴结束的位置
      color = "#585858",
      linewidth = 0.8,
      alpha = 0.6,
      arrow = ggplot2::arrow(angle = 35, length = ggplot2::unit(0.3, "cm")))
  
  
  ##
  #给箭头添加标签
  p1 <- p1 + 
    ggrepel::geom_text_repel(
      data = data[["env"]],
      ggplot2::aes(
        x = data[["env"]][, 1],
        y = data[["env"]][, 2],
        label = rownames(data[["env"]])
      ),
      size = 5,
      color = "#000000",
      box.padding = ggplot2::unit(0.45, "lines"),  # 控制标签周围的空间
      alpha = 0.75
    )
  
  
  ## 配色方案
  if(!is.null(color_scheme)) {
    
    # 自定义点的颜色设置
    color_scheme_point <- color_scheme          # 点填充颜色
    color_scheme_ellipse <- color_scheme_point  # 置信椭圆填充颜色
    
    p1 <- p1 + 
      # 点颜色
      ggplot2::scale_color_manual(values = color_scheme_point) +
      
      # 轮廓颜色
      ggplot2::scale_fill_manual(values = color_scheme_ellipse)
  }
  
  
  
  # ##
  # # 保存文件
  # #
  # ggplot2::ggsave(filename = paste0(filename, ".png"), plot = p1, width = file_width, height = file_height)  # 保存为 PNG 文件
  # ggplot2::ggsave(filename = paste0(filename, ".pdf"), plot = p1, width = file_width, height = file_height)  # 保存为 PNG 文件
  # 
  ##
  cat("\033[32mtaxa_bar: success!\033[0m\n")
  cat("\033[0;32m", "The file has been saved to \n",
      getwd(), "\033[0m\n", sep = "")
  
  return(p1)
}

