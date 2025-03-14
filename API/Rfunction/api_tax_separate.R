# Tax 去前缀

source("./Rfunction/amplysis/tax_separate.R")

# ------------------------------------------------------------------------------
api_tax_separate <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  # 提取参数并赋值给变量
  tax <- body$taxonomyData
  nCol <- as.numeric(body$nCol)
  delimiter <- body$delimiter
  colName <- body$colName
  
  
  
  # 如果 Tax 表为空或维度为 0，则停止执行
  if (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) {
    # 错误信息：OTU 表为空
    message("错误: Tax 表为空或没有有效数据。")
    
    # 返回结果
    tax = -1
    result <- list(tax_separated = tax)
    return(result)
  }
  
  
  
  # 打印数据框的维度和内容
  cat("\nTax 表的纬度: ")
  cat(dim(tax), "\n")  # 打印行数和列数
  
  
  cat("\n前端传入的参数：", "\n")
  cat(paste("nCol:", nCol), "\n")
  cat(paste("delimiter:", delimiter), "\n")
  
  # 转换并输出列名
  names = NULL
  for (i in 1:length(colName)) {
    names = c(names, colName[i])
  }
  cat("colName: ")
  cat(names, "\n")
  
  # head(tax)
  # str(tax)
  
  
  # 执行 tax_separate 函数
  result = tax_separate(
    tax = tax,           # 含有 tax 列的数据表格
    index = nCol,        # taxonomy 列列号
    delim = delimiter,   # 使用分隔符
    names = names      # 列名
  )
  
  
  cat("tax_separate()：运行成功!", "\n")
  
  
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    nCol = nCol,
    delimiter = delimiter,
    colName = colName,
    
    tax_separated = result
  ))
}





