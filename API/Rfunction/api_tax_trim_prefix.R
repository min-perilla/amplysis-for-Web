# Tax 去前缀

source("./Rfunction/amplysis/tax_trim_prefix.R")
source("./Rfunction/amplysis/parse_input_vector.R")  # 将字符转换为向量

# ------------------------------------------------------------------------------
api_tax_trim_prefix <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  # 提取参数并赋值给变量
  tax <- body$taxonomyData
  index <- body$prefix_index
  length <- as.numeric(body$prefix_length)
  
  
  cat("tax: ", class(tax), "\n")
  cat("index: ", class(index), "\n")
  cat("length: ", class(length), "\n")
  
  
  # 如果 Tax 表为空或维度为 0，则停止执行
  if (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) {
    # 错误信息：OTU 表为空
    message("错误: Tax 表为空或没有有效数据。")
    
    # 返回结果
    tax = -1
    result <- list(tax_trimmed = tax)
    return(result)
  }
  
  
  # 打印数据框的维度和内容
  cat("\nTax 表的纬度: ")
  cat(dim(tax), "\n")  # 打印行数和列数
  
  
  cat("\n前端传入的参数：", "\n")
  cat(paste("index:", index), "\n")
  cat(paste("length:", length), "\n")
  
  
  # 处理参数 index
  index = parse_input_vector(index)
  cat("\n经过处理后的 index: ")
  print(index)
  
  
  # 执行 tax_trim_prefix 函数
  result <- tax_trim_prefix(
    tax = tax,       # 含有分类信息的数据表格
    index = index,   # 需要修复的分类信息在哪几列，如：index = 3，index = c(2:8)
    length = length  # 前缀的长度
  )
  
  tax = result
  cat("\ntax_trim_prefix()：运行成功!", "\n")
  
  # 返回 tax 之前，将所有 NA 值处理成空字符串""
  tax[is.na(tax)] <- ""
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    index = index,
    length = length,
    
    tax_trimmed = tax
  ))
}





