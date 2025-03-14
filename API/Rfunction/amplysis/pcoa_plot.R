# 如果没有安装必要的包，则先安装
required_packages <- c("ggplot2", "dplyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(ggplot2)
library(dplyr)

# POcA
pcoa_plot <- function(
    data,                    # 绘图数据
    color_scheme = NULL,     # 配色方案
    # group = "group",         # 分组信息
    custom_order = NULL,     # 自定义图例排序
    seed = 123,              # 设置种子
    
    # 图形外观
    size_point = 4.5,        # 点大小
    size_point_legend = 8,   # 图例点大小
    spacing_legend_point = 1.2,  # 图例内部间距
    spacing_legend_title = 0.5,  # 图例标题与正文的间距
    legend_ncol = 1,         # 图例列数
    label_is = T,            # 是否显示数据标签
    size_label = 5,          # 标签大小
    label_font_color = NULL, # 标签字体颜色，默认使用分组颜色
    
    # 标题设置
    title = "PCoA",          # 大标题
    title_sub = NULL,        # 副标题
    title_legend = "Group",  # 图例标题
    
    # 字号设置
    size_title = 28,         # 大标题字号
    size_title_sub = 16,     # 副标题字号
    size_title_x = 20,       # 横坐标标题字号
    size_title_y = 20,       # 纵坐标标题字号
    size_title_legend = 24,  # 图例标题字号
    
    size_x = 18,             # 横坐标刻度字符字号
    size_y = 18,             # 纵坐标刻度字符字号
    size_legend = 16,        # 图例正文字号
    
    # 保存文件
    filename = "PCoA",       # 保存文件名
    file_width = 12,         # 图像宽度
    file_height = 9          # 图像高度
)
{
  # 种子设置
  set.seed(seed = seed)
  
  group = "group"          # 分组信息
  
  # 判断是否显示数据标签
  if(isTRUE(label_is)) {
    labelNum = 200
  }else{
    labelNum = 0
  }
  
  # 自定义图例排序
  if(!is.null(custom_order)){
    data[["PCoA"]][["group"]] <- factor(data[["PCoA"]][["group"]], levels = custom_order)
    data[["PCoA"]] <- dplyr::arrange(data[["PCoA"]], group)
    
    cat("Custom legend order: ", custom_order, sep = "")
  }
  
  pc = NULL
  
  #坐标轴百分比保留两位小数
  pc[1] <- round(data[["PoA"]][1], 2)
  pc[2] <- round(data[["PoA"]][2], 2)
  
  #横纵坐标命名
  xName = paste0("PCo1 (", pc[1], "%)")
  yName = paste0("PCo2 (", pc[2], "%)")
  
  
  # 转化为符号
  # 转换成符号对象
  group_sym <- rlang::sym(group)
  
  
  ##
  #绘制散点图
  p1 <- ggplot2::ggplot(
    # 设置绘图数据，x 轴和 y 轴，颜色，形状
    data = data[["PCoA"]],  
    ggplot2::aes(x = data[["PCoA"]][["PC1"]], 
                 y = data[["PCoA"]][["PC2"]], 
                 color = !!group_sym, shape = !!group_sym)) +  
    
    # 主题配色设置
    ggplot2::theme_bw() +  # 设置主题为白色背景、黑色线条的风格
    
    # 图形设置
    ggplot2::geom_vline(xintercept = 0, lty = "dashed", alpha = 0.2) +  # 添加垂直虚线
    ggplot2::geom_hline(yintercept = 0, lty = "dashed", alpha = 0.2) +  # 添加水平虚线
    ggplot2::geom_point(size = size_point) +                            # 设置点的大小
    ggplot2::theme(panel.grid = ggplot2::element_blank())             # 去除网格线
    
  
  ## 添加自适应标签
  if (is.null(label_font_color)) {  # 标签字体默认配色
    p1 <- p1 + 
      ggrepel::geom_text_repel(
        ggplot2::aes(label = sample), 
        size = size_label, 
        box.padding = ggplot2::unit(0.6, "lines"), 
        point.padding = ggplot2::unit(0.5, "lines"), 
        max.overlaps = labelNum, alpha = 0.8, show.legend = F, seed = seed)
  } else {
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
    
    # 横纵坐标刻度标签
    ggplot2::labs(x = xName,    #设置 x 轴标签
                  y = yName) +  #设置 y 轴标签
    
    # 添加置信椭圆
    ggplot2::stat_ellipse(data = data[["PCoA"]], 
                          geom = "polygon",
                          level = 0.95,       #level：置信水平
                          linetype = 2,       #线型样式
                          linewidth = 0.4, 
                          ggplot2::aes(fill = group), 
                          alpha = 0.15, 
                          show.legend = F) +
    
    # 设置大标题
    ggplot2::labs(title = title) +
    # 大标题字号
    ggplot2::theme(plot.title = ggplot2::element_text(
      face = "bold", size = size_title, hjust = 0.5)) +   # hjust参数（取值范围 0 到 1）控制文本相对于其位置的水平对齐方式
    
    # 设置副标题
    ggplot2::labs(subtitle = title_sub) + 
    # 副标题字号
    ggplot2::theme(plot.subtitle = ggplot2::element_text(
      face = "bold", size = size_title_sub, hjust = 0)) +  # hjust参数（取值范围 0 到 1）控制文本相对于其位置的水平对齐方式
    
    
    # 刻度字号设置
    ggplot2::theme(axis.title.x = ggplot2::element_text(size = size_title_x),              # 修改X轴标题文本
                   axis.title.y = ggplot2::element_text(size = size_title_y, angle = 90),  # 修改y轴标题文本
                   axis.text.x = ggplot2::element_text(size = size_x),                     # 修改x轴刻度标签文本
                   axis.text.y = ggplot2::element_text(size = size_y)) +                   # 修改y轴刻度标签文本
    
    # 设置图例
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
    ggplot2::theme(legend.title = ggplot2::element_text(hjust = 0.5)) + # 图例标题居中

    # 图例内部间距
    ggplot2::theme(legend.key.height = ggplot2::unit(
      spacing_legend_point, "cm")) + 
    # 图例标题与正文的间距
    ggplot2::theme(legend.title = ggplot2::element_text(
      margin = ggplot2::margin(b = spacing_legend_title, unit = 'cm'))) + 
    
    
    # 边距设置：t表示顶部边距，b表示底部边距，r表示右边距，l表示左边距
    # 大标题边距
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
  
  
  ##
  # 保存文件
  #
  # ggplot2::ggsave(filename = paste0(filename, ".png"), plot = p1, width = file_width, height = file_height)  # 保存为 PNG 文件
  # ggplot2::ggsave(filename = paste0(filename, ".pdf"), plot = p1, width = file_width, height = file_height)  # 保存为 PNG 文件
  
  ##
  cat("\033[32mtaxa_bar: success!\033[0m\n")
  cat("\033[0;32m", "The file has been saved to \n",
      getwd(), "\033[0m\n", sep = "")
  
  return(p1)
}

