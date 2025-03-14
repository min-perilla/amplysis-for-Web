if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

library(dplyr)

tax_names_repair <- function(tax,            # 包含 tax 数据的表格
                             column_to_check,  # 要修复的列，如 column_to_check = 8, column_to_check = c(4:8),
                             # 如果知道列名，也可以输入 column_to_check = "列名"
                             column_to_add     # 若 column_to_check 为未分类，要添加哪 1 列信息为后缀
) {
  # 格式检查：column_to_check
  if (is.numeric(column_to_check) && any(floor(column_to_check) != column_to_check)) {
    stop("column_to_check 必须为整数!")
  }
  
  # 格式检查：column_to_add
  if (!(is.numeric(column_to_add) && length(column_to_add) == 1) &&
      !(is.character(column_to_add) && length(column_to_add) == 1)) {
    stop("column_to_add 必须是单个整数或单个字符串!")
  }
  
  # 格式检查：确保 column_to_check 和 column_to_add 不相同
  if (!is.null(column_to_check) && !is.null(column_to_add)) {
    if (identical(column_to_check, column_to_add)) {
      stop("column_to_check 和 column_to_add 不能相同!")
    }
  }
  
  # 定义模式列表
  patterns <- base::tolower(c("unclassified", "unknown", "uncultured", "norank", "unidentified",
                              "Unknown_Species", "Unknown_Genus", "Unknown_Family",
                              "Unknown_Order", "Unknown_Class", "Unknown_Phylum"))
  
  # 应用模式并添加后缀
  tax <- dplyr::mutate_at(tax, dplyr::vars(dplyr::all_of(column_to_check)), function(x) {
    ifelse(base::tolower(x) %in% patterns, paste0(x, '_', tax[[column_to_add]]), x)
  })
  
  return(tax)
}