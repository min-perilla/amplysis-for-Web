# 如果没有安装必要的包，则先安装
required_packages <- c("tidyverse", "ggplot2")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(tidyverse)
library(ggplot2)

##物种组成堆叠柱形图
taxa_bar_plot <- function(data,                    # 绘图数据
                          color_scheme = NULL,     # 配色方案
                          tax_cla,                 # 分类等级
                          x_group = "group",       # 分组 1（x 轴）
                          facet_group = NULL,      # 分组 2，用于分面图，请输入 metadata 中第二分组的列名
                          y_abun = "abun",         # 丰度信息（y 轴）
                          custom_order = NULL,     # 自定义横坐标顺序
                          custom_order_F = NULL,   # 分面图自定义横坐标顺序

                          # 图形外观
                          bar_type = "fill",       # 堆叠图类型。fill：相对丰度堆叠图；stack：绝对丰度堆叠图
                          bar_width = 0.7,         # 堆叠图柱形宽度
                          grid_line = F,           # 网格线
                          size_point_legend = 0.75,     # 图例点大小
                          spacing_legend_point = 0.75,  # 图例内部间距
                          spacing_legend_title = 0.5,   # 图例标题与正文的间距
                          legend_ncol = 1,         # 图例列数
                          
                          # 标题设置
                          title = NULL,            # 大标题
                          title_x = "Groups",      # 横坐标标题
                          title_y = NULL,          # 纵坐标标题
                          title_legend = NULL,     # 图例标题

                          # 字号设置
                          size_title = 28,         # 大标题字号
                          size_title_x = 24,       # 横坐标标题字号
                          size_title_y = 24,       # 纵坐标标题字号
                          size_title_legned = 24,  # 图例标题字号
                          size_title_facet = 32,   # 分面图标题字号
                          
                          size_x = 18,             # 横坐标刻度字符字号
                          size_y = 18,             # 纵坐标刻度字符字号
                          size_legned = 16,        # 图例正文字号
                          
                          # 保存文件
                          filename = NULL,         # 保存文件名
                          file_width = 16,         # 图像宽度
                          file_height = 9          # 图像高度
                          )
{
  ##
  # 自定义横坐标顺序
  if(!is.null(custom_order)) {
    # 启用自定义横坐标顺序
    # 将 group 列转换为因子类型，并按照自定义顺序排序

    # library(rlang)
    # data = taxa
    # x_group = "group"
    # custom_order = c("AA", "AAK", "AB", "ABK", "AR", "ARK", "AD", "ADK",
    #                  "BA", "BAK", "BB", "BBK", "BR", "BRK", "BD", "BDK",
    #                  "RA", "RAK", "RB", "RBK", "RR", "RRK", "RD", "RDK",
    #                  "DA", "DAK", "DB", "DBK", "DR", "DRK", "DD", "DDK",
    #                  "Soil")

    # 将字符串参数转换为符号对象
    x_group_sym <- rlang::sym(x_group)

    # 对指定列进行转换为因子类型并排序
    data <- data %>%
      dplyr::mutate(!!x_group_sym := factor(!!x_group_sym, levels = custom_order)) %>%
      dplyr::arrange(!!x_group_sym)

    ###############################
    # 以下两行代码已被弃用
    # data$group <- factor(x = data$group, levels = custom_order)
    # data <- arrange(data, group)
    ###############################

    cat("自定义横坐标顺序：", custom_order, "\n")

  }


  ##
  # 分面图
  if(is.null(facet_group)){
    #不启用分面图
    facet_grid2 = ". ~ ."


  } else {
    #启用分面图
    facet_grid2 = paste0(". ~ ", facet_group)

    # 分面图自定义横坐标顺序
    if(!is.null(custom_order_F)) {
      # 启用自定义横坐标顺序
      # 将 group 列转换为因子类型并按照自定义顺序排序

      # library(rlang)
      # data = taxa
      # facet_group = "group2"
      # custom_order_F = c("A", "B", "R", "D", "S")

      # 将字符串参数转换为符号对象
      facet_group_sym <- rlang::sym(facet_group)

      # 对指定列进行转换为因子类型并排序
      data <- data %>%
        dplyr::mutate(!!facet_group_sym := factor(!!facet_group_sym, levels = custom_order_F)) %>%
        dplyr::arrange(!!facet_group_sym)

      ###############################
      # 以下两行代码已被弃用
      # data$group2 <- factor(data$group2, levels = custom_order_F)
      # data <- arrange(data, group2)
      ###############################

      cat("自定义分面图横坐标顺序：", custom_order_F, "\n")
    }
  }


  ##
  # 纵坐标标题
  if(bar_type == "fill") {
    # 相对丰度堆叠图
    label_y = ggplot2::scale_y_continuous(
      name = if(is.null(title_y)){ "Relative abundance (%)" } else { title_y },
      limits = c(0,1),
      breaks = seq(0, 1, 0.25),
      labels = paste(seq(0, 100, 25), "%"))


  } else if(bar_type == "stack") {
    # 绝对丰度堆叠图
    label_y = ggplot2::scale_y_continuous(
      name = if(is.null(title_y)){ "Relative abundance (%)" } else { title_y })


  } else {
    stop("形参 `bar_type` 输入错误，请输入正确的参数：\"fill\" 或 \"stack\"！")
  }


  ##
  # 网格线
  if(isFALSE(grid_line)){
    # 不启用网格线
    panel_grid = ggplot2::element_blank()


  } else {
    # 启用网格线
    panel_grid = ggplot2::element_line(color = "gray", linewidth = 0.2, linetype = "dashed")
  }


  ##
  # 图例标题
  if(is.null(title_legend)) {
    # 启用自适应图例标题
    title_legend = deparse(substitute(tax_cla))  # 获取标题
    title_legend <- tolower(title_legend)        # 将字符串转换为小写
    title_legend <- stringr::str_to_title(title_legend)   # 将字符串中每个单词的首字母转换为大写


    # 启用自定义图例标题
  } else { }


  ##
  #配色方案
  # 检查 color_scheme 是否需要设置为 NULL
  if (!is.null(color_scheme) && (all(color_scheme == "") || all(grepl("^\\s*$", color_scheme)))) {
    color_scheme <- NULL
  }
  
  
  if (is.null(color_scheme)) {
    # 默认配色方案
    color_scheme = c("#7FC97F", "#BEAED4", "#FDC086", "#FFFF99", "#386CB0",
                     "#F0027F", "#1ba7e5", "#66C2A5", "#FC8D62", "#8DA0CB",
                     "#E78AC3", "#FFD92F", "#E5C494", "#95beae", "#FF7F00",
                     "#E31A1C", "#FB9A99", "#33A02C", "#A6CEE3", "#95be3e",
                     "#7F217F", "#2EAED4", "#ADC086", "#BFFF99", "#C86CB0",
                     "#DE023F", "#E8a745", "#F6C2A5", "#AC2D62", "#ADA0CB",
                     "#B78AC3", "#CFD92F", "#D5C494", "#E5beae", "#AF7F00",
                     "#B31A1C", "#CB9A99", "#D3A02C", "#EE6CE3", "#F12e3e",
                     "#413dAC", "#2EAEA4", "#B43086", "#BFDF99", "#C84A30"
                     )

    # 自动将最后一个颜色变成灰色 "#7f7f7f"
    color_n <- max(1, length(unique(data[[tax_cla]])) - 1)  # 获取需要的颜色个数
    color_scheme2 <- color_scheme[1:color_n]          # 提取相应数量的颜色
    color_scheme2 <- c(color_scheme2, "#7f7f7f")      # 添加灰色到末尾
    
  } else {
    # 假设用户输入的物种数量是 8，那么就需要 8+1 种颜色，因为 "Others" 需要一个灰色，这个将默认添加 
    # 添加一个颜色：灰色 "#7f7f7f"
    color_n <- max(1, length(unique(data[[tax_cla]])) - 1)   # 获取需要的颜色个数
    color_scheme2 <- color_scheme[1:color_n]         # 提取相应数量的颜色 
    color_scheme2 <- c(color_scheme2, "#7f7f7f")     # 添加灰色到末尾
  }
  
  
  ##
  # 将字符串转换为符号对象
  tax_cla <- rlang::sym(tax_cla)
  x_group <- rlang::sym(x_group)
  y_abun <- rlang::sym(y_abun)
  

  ##
  p <- ggplot2::ggplot() +

    ##
    # 绘图参数
    ggplot2::geom_bar(data = data,                            # 绘图数据
                      # aes(x = !!dplyr::enquo(x_group),      # X 轴（分组）
                      #     weight = !!dplyr::enquo(y_abun),  # Y 轴（丰度）
                      ggplot2::aes(x = !!x_group,             # X 轴（分组）
                                   weight = !!y_abun,         # Y 轴（丰度）


                                   # 将 "others" 放在最后
                                   # fill = fct_relevel(!!dplyr::enquo(tax_cla), after = Inf, "others")),
                                   fill = forcats::fct_relevel(stringr::str_to_title(!!tax_cla), after = Inf, "Others")),
                      position = bar_type,    # 堆叠图类型，可选："fill" 或 "stack"
                      width = bar_width) +


    ##
    # 主题配色设置
    ggplot2::theme_bw() +  # 白色背景和黑色线条
    ggplot2::scale_fill_manual(values = color_scheme2) +  # 配色
    ggplot2::theme(panel.grid = panel_grid) +  # 网格线
    # 图形边距设置
    ggplot2::theme(plot.margin = ggplot2::margin(t = 30, r = 40, b = 30, l = 40, unit = "pt")) +


    ##
    # 大标题设置
    ggplot2::labs(title = title) +
    ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = size_title, hjust = 0.5)) +  # hjust参数（取值范围0到1）控制文本相对于其位置的水平对齐方式
    # 大标题边距
    ggplot2::theme(plot.title = ggplot2::element_text(margin = ggplot2::margin(t = 0, r = 0, b = 15, l = 0, unit = "pt"))) +


    ##
    # 横坐标设置
    ggplot2::labs(x = title_x) +  # 横坐标标题
    # 横坐标字号
    ggplot2::theme(axis.title.x = ggplot2::element_text(face = "bold", size = size_title_x, color = "black")) +  # 标题
    ggplot2::theme(axis.text.x = ggplot2::element_text(face = "bold", size = size_x, color = "black")) +           # 刻度
    # 横坐标边距
    ggplot2::theme(axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10, r = 0, b = 0, l = 0, unit = "pt"))) +


    ##
    # 纵坐标设置
    label_y +  # 纵坐标标题
    # 纵坐标字号
    ggplot2::theme(axis.title.y = ggplot2::element_text(face = "bold", size = size_title_y, color = "black")) +  # 标题
    ggplot2::theme(axis.text.y = ggplot2::element_text(face = "bold", size = size_y, color = "black")) +           # 刻度
    # 纵坐标边距
    ggplot2::theme(axis.title.y = ggplot2::element_text(margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0, unit = "pt"))) +


    ##
    # 图例设置
    # title 图例标题，ncol 表示一行放几个图例
    ggplot2::guides(fill = ggplot2::guide_legend(title = title_legend, ncol = legend_ncol)) +
    ggplot2::theme(legend.position = "right") +  # 图例存放位置，right 表示放在右边
    # 图例字号
    ggplot2::theme(legend.title = ggplot2::element_text(face = "bold", size = size_title_legned, color = "black")) +  # 标题大小
    ggplot2::theme(legend.text = ggplot2::element_text(face = "bold.italic", size = size_legned, color = "black")) +  # 字体、字号
    
    # 图例图标点大小
    ggplot2::theme(legend.key.size = unit(size_point_legend, "cm")) +   
    # 图例内部间距
    ggplot2::theme(legend.key.spacing.y = ggplot2::unit(
      spacing_legend_point, "pt")) + 
    # 图例标题与正文的间距
    ggplot2::theme(legend.title = element_text(
      margin = ggplot2::margin(b = spacing_legend_title, unit = 'cm'))) + 
    
    # 图例边距
    ggplot2::theme(legend.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 20, unit = "pt")) +

    # 分面图
    ggplot2::facet_grid(facet_grid2, scales = "free") +  #还有 facet_wrap
    ggplot2::theme(strip.text.x = ggplot2::element_text(face = "bold", size = size_title_facet, color = "black"))  #用来调整分面图的字号


  ##
  # 保存文件
  # 文件名
  # if(is.null(filename) || filename == "") {
  #   # tax_cla = "genus"
  #   # tax_cla <- rlang::sym(tax_cla)
  # 
  #   # 启用自适应文件名
  #   filename <- as.character(rlang::quo_text(tax_cla))  # 将符号对象重新转换回字符
  # 
  #   # 自定义文件名
  # } else {  }
  
  
  # 保存文件
  # ggplot2::ggsave(filename = paste0(filename, ".png"), plot = p, width = file_width, height = file_height)  # 保存为 PNG 文件
  # ggplot2::ggsave(filename = paste0(filename, ".pdf"), plot = p, width = file_width, height = file_height)  # 保存为 PNG 文件

  ##
  # cat("\033[32mtaxa_bar: success!\033[0m\n")
  # cat("\033[0;32m", "The file has been saved to \n",
  #     getwd(), "\033[0m\n", sep = "")
  
  
  return(p)
}


