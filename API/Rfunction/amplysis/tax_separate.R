if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}

library(tidyr)

tax_separate <- function(
    tax,               # 含有 tax 列的数据表格
    index,             # taxonomy 列列号
    delim = NULL,      # 使用分隔符
    names = c("domain", "phylum", "class", "order", "family", "genus", "species")  # 数据分列后，各列列名。默认 7 列
) {
  
  # 保存原数据的行名
  tax_rownames <- rownames(tax)
  
  # 数据分列功能调用 R 包 tidyr 中的 separate_wider_delim() 函数
  tax_separated <- tidyr::separate_wider_delim(
    data = tax,
    cols = tidyr::all_of(index),  # 防止歧义，使用 tidyselect::all_of() 函数
    delim = delim,
    names = names,                # 数据拆分后，各列列名
    
    # 拆分后的列数，小于 names 的列名数时
    too_few = "align_start",      # align_start：对齐开头，后面缺失的数据全部用 NA 代替
    
    # 拆分后的列数，大于 names 的列名数时
    too_many = "merge"            # merge：将多出的列合并
  )
  
  # 复原行名
  tax_separated <- as.data.frame(tax_separated)
  rownames(tax_separated) <- tax_rownames
  
  # 提示信息
  cat("\n数据拆分成功！\n",
      "cols: ", index, "\n",
      "delim: `", delim, "`\n",
      sep = "")
  
  # 返回分类表格
  return(tax_separated)
}