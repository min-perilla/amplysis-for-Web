

tax_trim_prefix <- function(tax,         # 含有分类信息的数据表格
                            index,       # 需要修复的分类信息在哪几列，如：index = 3，index = c(2:8)
                            length     # 前缀的长度
) {
  table2 <- tax
  
  pattern = paste0("^.{", length, "}")  # 正则表达式
  
  # 定义一个函数，用于对每一个单元格应用gsub函数
  remove_pattern <- function(x, pattern) { 
    base::gsub(pattern = pattern, replacement = "", x = x)}
  
  # 使用 apply() 遍历指定列，并对每一列应用 remove_pattern() 函数
  result <- base::apply(
    X = table2[, index, drop = F], MARGIN = 2, 
    FUN = function(col)
    { base::sapply(X = col, FUN = remove_pattern, pattern = pattern) }
  )
  
  # 替换原来的值
  result <- as.data.frame(result)
  table2[, index] <- result
  
  return(table2)
}