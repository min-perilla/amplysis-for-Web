# 如果没有安装必要的包，则先安装
required_packages <- c("ggvenn")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(ggvenn)

##
venn_plot <- function(
    data,                 # 绘图数据
    color_scheme = NULL,  # 配色方案
    
    # 图形外观
    show_percentage = T,  # 显示百分比
    digits = 2,           # 更改百分比保留小数
    
    # 字号设置
    size_set_name = 12,   # 各数据集标题大小
    size_text = 7,        # 图内字体大小
    
    # 保存文件
    filename = NULL,      # 保存文件名
    file_width = 12,      # 图像宽度
    file_height = 9       # 图像高度
) {

  # 处理数据，转换为布尔值
  otu <- as.data.frame(data > 0)

  # 删除值都为 FALSE 的行
  otu <- otu[rowSums(otu) > 0, ]


  ##
  # 配色方案
  if(is.null(color_scheme)) {
    color_scheme = c('#fff200','#0082ff',"#ff2d34","#7777ff", "#79ff79")
  }


  ##
  p1 <- ggvenn::ggvenn(
    otu,  #绘图数据

    #填充颜色
    fill_color = color_scheme,  # 自定义填充颜色
    fill_alpha = 0.45,          # 自定义填充色透明度

    #边框颜色
    stroke_color = "white",    # 边框线条色彩
    stroke_alpha = 1,          # 边框线条透明度
    stroke_size = 0.1,         # 边框线条宽度
    stroke_linetype = 1,       # 边框线条类型：0 无；1 实线；2 虚线...

    # 数据集标题
    set_name_color = "black",  # 字体颜色
    set_name_size = size_set_name,  # 字体大小

    # 图内字体
    text_color = "black",      # 字体颜色
    text_size = size_text,     # 字体大小

    #其他
    show_percentage = show_percentage,  # 显示百分比
    digits = digits,                    # 更改百分比保留小数  
  )

  
  ##
  # 添加边距
  p2 <- p1 +
    ggplot2::coord_cartesian(clip = "off") +  # 禁止裁剪
    ggplot2::theme(aspect.ratio = 3 / 4) +  # 设置长宽比
    ggplot2::theme(plot.margin = ggplot2::margin(
      t = 50, r = 20, b = 50, l = 20, unit = "pt"))
  
  
  cat("Venn 图绘制成功！\n")
  return(p2)
}


