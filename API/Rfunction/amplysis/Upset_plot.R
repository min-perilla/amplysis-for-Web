# 如果没有安装必要的包，则先安装
required_packages <- c("UpSetR")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {install.packages(new_packages)}

library(UpSetR)


# 绘制集合图
Upset_plot <- function(
    data,                     # 绘图数据
    
    # x 轴色彩
    color_matrix = NULL,      # matrix 图中的柱状图配色方案  ✅
    
    n = 40,                   # bar 图柱状图显示的柱子数量
    custom_order = NULL,      # bar 图 x 轴顺序
    order_by = "freq",        # matrix 图排序顺序，可选 "freq" 或 "degree"
    
    # 图形外观
    mb.ratio = c(0.6, 0.4),   # bar plot 和 matrix plot 图形高度的占比
    size_point = 2,           # matrix 图点的大小
    
    color_point = "#505050",  # matrix 图点的颜色  ✅
    color_matrix_shade = "#f89c9f",  # matrix 图中阴影部分的颜色 ✅
    color_bar = '#505050',    # bar 图 y 轴柱状图柱子颜色 ✅
    
    
    # 标题设置
    title_matrix_x = "Set Size",        # matrix 图 x 轴的标签
    title_bar_y = "Intersection Size",  # bar 图 Y 轴标题
    
    
    # 字号设置
    size_title_matrix_x = 2,      # matrix 图 x 轴标题字号
    size_title_matrix_y = 1.7,    # matrix 图 y 轴标题字号
    size_title_bar_y = 2,         # bar 图纵坐标标题字号
    
    size_matrix_x = 2,            # matrix 图刻度标签大小
    size_bar_y = 2,               # bar 图纵坐标刻度字符字号
    size_bar_label = 1.75,        # bar 图柱子数字大小
    queries = NULL,               # list(), 高亮显示 matrix 图中的特定交集
    
    # 保存文件
    filename = "Upset",      # 保存文件名
    file_width = 16,         # 图像宽度
    file_height = 9          # 图像高度
) {
  # 转换为小写
  order_by <- tolower(order_by)
  
  # 检测 order_by 的值
  if(!order_by %in% c("freq", "degree")) {
    cat("Please enter 'freq' or 'degree'!\n")
    order_by <- "freq"
    cat("The formal argument `order_by` has been reset to \"freq\".\n")
  }
  
  
  # 顺序
  custom_order = rev(custom_order) # 倒叙
  
  
  ##
  # 转化数据
  df <- list()  # 初始化列表
  
  
  ##
  # 获取每个样本（组）中所有的 OTU
  for (i in 1:length(colnames(data))){
    group <- colnames(data)[i]
    df[[group]] <- rownames(data)[which(data[,i] != 0)]
  }
  
  
  ##
  # 配置 set 图 bar 色彩
  if(is.null(color_matrix)) {
    color_matrix = c("#3d97cb", "#57b9e5", "#8ae0ff", "#b0eaff",
                     "#ff4f24", "#ff7752", "#ffab7c", "#ffd9be",
                     "#038d6f", "#2ebe8c", "#48e092", "#70ffa9",
                     "#8f38ff", "#ae75ed", "#c886f2", "#e7a3c6", 
                     "#ffca18", "#ffdb63", "#ffe899", "#fff3cc", 
                     "#00fff6", "#4aebe5", "#8aefeb", "#d3f5f4",
                     "#ff2aba", "#fe70d0", "#ecaad7", "#ffe6f2")
    
    # 取色彩
    num_df <- length(df)
    num_color <- length(color_matrix)
    
    # 如果色彩数量够
    if(num_color >= num_df) {
      color_matrix2 <- color_matrix[1: num_df]
      
      
      # 如果色彩数量不够
    } else {
      color_matrix <- c(color_matrix, color_matrix, color_matrix, color_matrix)
      color_matrix2 <- color_matrix[1: num_df]
    }
    
    
    # color_matrix 非空
  } else {
    # 取色彩
    num_df <- length(df)
    num_color <- length(color_matrix)
    
    color_matrix2 <- color_matrix[1: num_df]
  }
  
  
  
  ###
  # ?UpSetR::upset()
  p1 <- UpSetR::upset(
    data = UpSetR::fromList(df),  # 绘图数据
    nsets = length(df),   # 显示数据集的数量
    nintersects = n,      # 显示前多少个
    
    # 自定义顺序
    keep.order = TRUE,    # 保持集合按输入的顺序排序，使用自定义顺序
    sets = custom_order,  # 指定集合顺序
    
    # 图形参数
    number.angles = 0,         # 交互集合柱状图的柱标倾角
    point.size = size_point,   # 图中点的大小
    line.size = 1,             # 图中连接线粗细
    mb.ratio = mb.ratio,       # bar plot 和 matrix plot 图形高度的占比
    
    # 字号大小设置
    text.scale = c(size_title_bar_y,  # intersection size title（y 标题大小）
                   size_bar_y,        # intersection size tick labels（y 刻度标签大小）
                   size_title_matrix_x,  # set size title（set 标题大小）
                   size_matrix_x,        # set 刻度标签大小
                   size_title_matrix_y,  # set 分类标签大小
                   size_bar_label),   # 柱数字大小
    
    shade.color = color_matrix_shade,    # 图中阴影部分的颜色
    
    # 坐标轴参数
    # y 轴
    mainbar.y.label = title_bar_y,   # bar 图 y 轴的标签
    main.bar.color = color_bar,      # bar 图 y 轴柱状图颜色
    order.by = order_by,             # y 轴矩阵排序，如 "freq" 频率、"degree" 程度
    decreasing = c(T, F),            # 以上排序是否降序 c(FALSE, TRUE)
    
    # x 轴
    sets.x.label = title_matrix_x,      # set 图 x 轴的标签
    matrix.color = color_point,      # set 图 点的颜色
    
    # set bar 色彩
    sets.bar.color = color_matrix2,  # x 轴柱状图的颜色
    
    # 高亮展示某些分组
    queries = queries
    # queries = list(
    #   list(query = intersects, params = list("AA", "AB", "AD"),
    #        color="red", active = T),
    # 
    #   list(query = intersects, params = list(
    #     "AA", "AB"),
    #     color="red", active = T)
    # )
  )
  print(p1)
  
  ##
  cat("\033[0;32m", "The file has been saved to \n",
      getwd(), "\033[0m\n", sep = "")
  
  return(p1)
}


################################################################################

#绘制集合图
# p1 <- Upset_plot(
#     upset1,                   # 绘图数据
#     
#     # x 轴色彩
#     color_matrix = NULL,      # matrix 图中的柱状图配色方案
#     
#     n = 40,                   # bar 图柱状图显示的柱子数量
#     custom_order = NULL,      # bar 图 x 轴顺序
#     order_by = "freq",        # matrix 图排序顺序，可选 "freq" 或 "degree"
#     
#     # 图形外观
#     mb.ratio = c(0.6, 0.4),   # bar plot 和 matrix plot 图形高度的占比
#     size_point = 2,           # matrix 图点的大小
#     
#     color_point = "#505050",  # matrix 图点的颜色
#     color_matrix_shade = "#f89c9f",  # matrix 图中阴影部分的颜色
#     color_bar = '#505050',    # bar 图 y 轴柱状图柱子颜色
#     
#     
#     # 标题设置
#     title_matrix_x = "Set Size",        # matrix 图 x 轴的标签
#     title_bar_y = "Intersection Size",  # bar 图 Y 轴标题
#     
#     
#     # 字号设置
#     size_title_matrix_x = 2,      # matrix 图 x 轴标题字号
#     size_title_matrix_y = 1.7,    # matrix 图 y 轴标题字号
#     size_title_bar_y = 2,         # bar 图纵坐标标题字号
#     
#     size_matrix_x = 2,            # matrix 图刻度标签大小
#     size_bar_y = 2,               # bar 图纵坐标刻度字符字号
#     size_bar_label = 1.75,        # bar 图柱子数字大小
#     
#     # list(), 高亮显示 matrix 图中的特定交集
#     queries = list(
#       list(query = intersects, params = list("AA", "AB", "AD"),
#            color="#f06676", active = T),
#       
#       list(query = intersects, params = list("AA", "AB"),
#         color="#f06676", active = T)
#     )        
# )

