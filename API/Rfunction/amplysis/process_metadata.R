# 用来处理前端传回来的 metadata 中，对于缺失值的处理，将其转换为 NA

# 定义函数，处理 metadata 数据框中的缺失值
process_metadata <- function(metadata) {
  # 检查输入是否为 data.frame
  if (!is.data.frame(metadata)) {
    stop("Input metadata must be a data.frame.")
  }
  
  # 遍历数据框的每一列，将空字符串转换为 NA
  metadata[] <- lapply(metadata, function(column) {
    # 检查每列，如果值是空字符串，替换为 NA
    ifelse(column == "", NA, column)
  })
  
  cat("metadata 缺失值转换成功：\"\" -> NA\n")
  return(metadata)
}