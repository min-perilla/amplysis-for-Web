# 物种注释信息修复

source("./Rfunction/amplysis/tax_names_repair.R")
source("./Rfunction/amplysis/parse_input_vector.R")  # 将字符转换为向量

# ------------------------------------------------------------------------------
api_tax_names_repair <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  
  # 提取参数并赋值给变量
  tax <- body$taxonomyData
  index <- body$repair_index                      # 要进行修复的列号
  suffixCol <- as.numeric(body$repair_suffixCol)  # 作为后缀信息的列号
  
  
  cat("tax: ", class(tax), "\n")
  cat("index: ", class(index), "\n")
  cat("suffixCol: ", class(suffixCol), "\n")
  
  
  # 如果 Tax 表为空或维度为 0，则停止执行
  if (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) {
    # 错误信息：OTU 表为空
    message("错误: Tax 表为空或没有有效数据。")
    
    # 返回结果
    tax = -1
    result <- list(tax_repaired = tax)
    return(result)
  }
  
  
  # 打印数据框的维度和内容
  cat("\nTax 表的纬度: ")
  cat(dim(tax), "\n")  # 打印行数和列数
  
  
  cat("\n前端传入的参数：", "\n")
  cat(paste("index:", index), "\n")
  cat(paste("suffixCol:", suffixCol), "\n")
  
  
  
  # 处理参数 index
  index = parse_input_vector(index)
  cat("\n经过处理后的 index: ")
  print(index)
  str(index)
  
  
  # 执行 tax_names_repair 函数
  result <- tax_names_repair(
    tax = tax,                 # 包含 tax 数据的表格
    column_to_check = index,   # 要修复的列，如 column_to_check = 8, column_to_check = c(4:8),
    # 如果知道列名，也可以输入 column_to_check = "列名"
    column_to_add = suffixCol  # 若 column_to_check 为未分类，要添加哪 1 列信息为后缀
  )
  
  tax = result
  cat("tax_names_repair()：运行成功!", "\n")
  
  # print(tax)
  
  # 返回 tax 之前，将所有 NA 值处理成空字符串""
  tax[is.na(tax)] <- ""
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    index = index,
    suffixCol = suffixCol,
    tax_repaired = tax
  ))
}





