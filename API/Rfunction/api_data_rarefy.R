# Tax 去前缀

source("./Rfunction/amplysis/data_rarefy.R")

# ------------------------------------------------------------------------------
api_data_rarefy <- function(req) {
  # 解析请求体中的 JSON 数据
  body <- jsonlite::fromJSON(req$postBody)
  
  # 提取参数并赋值给变量
  otu <- body$featureData               # OTU
  tax <- body$taxonomyData              # Tax
  rep <- body$RepSeqsData               # Rep
  
  method <- body$method                 # 数据抽平方法
  seed <- as.numeric(body$seed)         # 随机种子
  replace <- as.logical(body$replace)   # 替代采样
  trimOTUs <- as.logical(body$trimOTUs) # 去除空 OTU
  alignTax <- as.logical(body$alignTax) # 对齐 Tax
  alignRep <- as.logical(body$alignRep) # 对齐 Rep
  
  
  cat("otu: ", class(otu), "\n")
  cat("tax: ", class(tax), "\n")
  cat("rep: ", class(rep), "\n")
  
  cat("method: ", class(method), "\n")
  cat("seed: ", class(seed), "\n")
  cat("replace: ", class(replace), "\n")
  cat("trimOTUs: ", class(trimOTUs), "\n")
  cat("alignTax: ", class(alignTax), "\n")
  cat("alignRep: ", class(alignRep), "\n")
  
  
  # 如果 OTU 表为空或维度为 0，则停止执行
  if (is.null(otu) || nrow(otu) == 0 || ncol(otu) == 0) {
    # 错误信息：OTU 表为空
    message("错误: OTU 表为空或没有有效数据。")
    
    # 返回结果
    otu = -1
    result <- list(otu_rarefy = otu)
    return(result)
  }
  
  
  # 处理 Tax 表
  # 如果 tax 表维度为 0，则将 tax 设置为 NULL
  if (is.null(tax) || nrow(tax) == 0 || ncol(tax) == 0) {
    # 错误信息：tax 表为空
    message("提示：Tax 表为空。")
    tax = NULL
  }
  
  # 如果不是同时开启了 trimOTUs 和 alignTax，则将 tax 设置为 NULL
  # 检查 trimOTUs 和 alignTax 是否同时为 TRUE
  if (!(trimOTUs && alignTax)) {
    tax <- NULL
  }
  
  
  ##
  # 处理 Rep 表
  # 如果 rep 表维度为 0，则将 rep 设置为 NULL
  if (is.null(rep) || nrow(rep) == 0 || ncol(rep) == 0) {
    # 错误信息：rep 表为空
    message("提示：Rep 表为空。")
    rep = NULL
  }
  
  # 如果不是同时开启了 trimOTUs 和 alignRep，则将 rep 设置为 NULL
  # 检查 trimOTUs 和 alignRep 是否同时为 TRUE
  if (!(trimOTUs && alignRep)) {
    rep <- NULL
  }
  
  
  
  ## OTU 数据类型转换
  # 转换第二列及之后的列为数值类型
  otu <- otu %>%
    mutate(across(2:ncol(otu), as.numeric))  # 从第 2 列到最后一列
  
  
  # 打印数据框的维度和内容
  cat("\nOTU 表的纬度: ")
  cat(dim(otu), "\n")  # 打印行数和列数
  
  if(!is.null(tax)) {
    cat("Tax 表的维度: ")
    cat(dim(tax), "\n")  # 打印行数和列数
  } else {
    cat(paste("tax: NULL", "\n"))
  }
  
  if(!is.null(rep)) {
    cat("Rep 表的维度: ")
    cat(dim(rep), "\n")  # 打印行数和列数
  } else {
    cat(paste("rep: NULL", "\n"))
  }
  
  
  
  cat("\n前端传入的其他参数：", "\n")
  cat(paste("method:", method), "\n")
  cat(paste("seed:", seed), "\n")
  cat(paste("replace:", replace), "\n")
  cat(paste("trimOTUs:", trimOTUs), "\n")
  cat(paste("alignTax:", alignTax), "\n")
  cat(paste("alignRep:", alignRep), "\n\n")
  
  
  
  # ------------------------------------------------------------------------------
  # 调用数据抽平函数
  result <- data_rarefy(
    file = otu, 
    id_col = 1,             # OTU_ID 列是第几列，默认为 0，则表示没有 OTU_ID 列，该数据已经为纯数字
    
    method = method,        # 抽平方法
    
    seed = seed,            # 如果抽平方法设置为 phyloseq，则必须设置随机种子
    replace = replace,      # 默认关闭替代采样。开启可以加快抽平速度，但是会导致某些 OTU 抽平后的计数大于原始值
    trimOTUs = trimOTUs,    # 是否移除每个样本的计数为零的 OTU
    
    tax_table = tax,        # 当 trimOTUs = T 时，可输入 tax_table 进行对齐，此时返回一个列表，包含 OTU 和 TAX。注意 tax 表的 OTU_ID 列与 otu 表要相同。
    
    write_file = FALSE      # 是否保存抽平后的文件，默认：TRUE
  )
  
  cat("data_rarefy()：运行成功!", "\n")
  

  # 检查 result 是否为 list
  # 当 tax 非空的时候，result 一定是个 list
  
  if (!is.null(tax) && is.list(result)) {
    otu_rarefy <- result[[1]]  # 从列表中提取第一个元素
    tax_align <- result[[2]]   # 从列表中提取第二个元素
  } else {
    otu_rarefy <- result      # 如果 result 不是列表，直接赋值
    tax_align <- tax          # tax 对齐赋值为原始 tax
  }
  
  
  
  ##
  # 对齐 Rep
  if(!is.null(rep) && isTRUE(alignRep)) {

    merged_data <- base::merge(x = otu_rarefy, y = rep, 
                               by.x = 1, by.y = 1, 
                               all.x = TRUE, sort = FALSE)
    
    # 获取 otu_rarefy 的列数（包括 OTU ID）
    otu_col_count <- ncol(otu_rarefy)
    
    # 提取 otu_rarefy 的数据（前 otu_col_count 列）
    otu_rarefy <- merged_data[, 1:otu_col_count]
    
    # 提取 rep 的数据（包含 OTU ID 和 rep 的其他列）
    rep <- merged_data[, c(1, (otu_col_count + 1):ncol(merged_data))]
    
    # 处理 rep 数据，把 NA 替换为空字符串 ""
    rep[is.na(rep)] <- ""
    
    cat("Rep 对齐成功!", "\n")
    # View(rep)
  } else {
    cat("无需对齐 Rep", "\n")
  }
  

  
  
  # ------------------------------------------------------------------------------
  # 返回成功消息和文件路径
  return(list(
    message = "后端已成功接收参数并处理",
    method = method,
    seed = seed,
    replace = replace,
    trimOTUs = trimOTUs,
    alignTax = alignTax,
    alignRep = alignRep,
    
    otuDim = dim(otu),
    taxDim = dim(tax),
    repDim = dim(rep),
    
    # 传给前端新数据
    otu_rarefy = otu_rarefy,
    tax_align = tax_align,
    rep = rep
  ))
}





