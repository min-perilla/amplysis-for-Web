# 将数字或者字符范围转换为R向量 c( , , , ...) 的形式
parse_input_vector <- function(position_string) {
  # 1. 标准化输入：去除空格并替换全角符号为半角符号
  position_string <- gsub(" ", "", position_string)  # 去空格
  position_string <- gsub("，", ",", position_string) # 替换全角逗号
  position_string <- gsub("：", ":", position_string) # 替换全角冒号
  
  # 2. 按逗号分割字符串
  parts <- unlist(strsplit(position_string, ","))
  
  # 3. 检查输入类型
  # 允许负数和小数，正确识别数字
  is_numeric <- grepl(":", parts) | grepl("^-?\\d+(\\.\\d+)?$", parts)  
  is_non_numeric <- !is_numeric
  
  if (any(is_numeric) & any(is_non_numeric)) {
    stop("输入中包含列名和数字范围的混合，请确保输入纯列名或纯数字范围。")
  }
  
  # 4. 如果全部是列名，返回字符向量
  if (all(is_non_numeric)) {
    cat("\n检测到列名，返回列名向量：\n")
    return(parts)
  }
  
  # 5. 初始化空结果向量
  result <- c()
  
  # 6. 解析为数值
  for (part in parts) {
    if (grepl(":", part)) {
      # 如果包含冒号，解析为范围并直接添加到结果
      result <- c(result, eval(parse(text = part)))  
    } else if (grepl("^-?\\d+(\\.\\d+)?$", part)) {
      # 允许负数和小数的匹配
      result <- c(result, as.numeric(part))
    }
  }
  
  # 7. 返回数值向量
  return(result)
}

# # 示例输入
# input1 <- "2, 3, 4"           # 全数字
# input2 <- "2:4"               # 数字范围
# input3 <- "2, 3, 4, 6:9"      # 数字范围和单个数字混合
# input4 <- "列名1,列名2,列名3"  # 全列名
# input5 <- "列名1,列名2,4:8"    # 列名与数字混合
# 
# # 测试函数
# print(parse_input_vector(input1))  # 输出：c(2, 3, 4)
# print(parse_input_vector(input2))  # 输出：c(2, 3, 4)
# print(parse_input_vector(input3))  # 输出：c(2, 3, 4, 6, 7, 8, 9)
# print(parse_input_vector(input4))  # 输出：c("列名1", "列名2", "列名3")
# print(parse_input_vector(input5))  # 输出：c("列名1", "列名2", 4, 5, 6, 7, 8)

# 可以输入负数和小数点
# input = "-1, 0, 1"
# parse_input_vector(input)

