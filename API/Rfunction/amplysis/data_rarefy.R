# 定义所需的包列表
required_packages <- c("vegan", "phyloseq")

# 检查并安装未安装的包
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# 加载所有包
lapply(required_packages, library, character.only = TRUE)

library(vegan)
library(phyloseq)


# 当使用 phyloseq 包的抽平方法时，且 trimOTUs = T，使用下列方法对齐 tax 和 otu 表格
align_otu_tax <- function(
    tax_table,       # 要对齐的第一个数据框
    otu_table,       # 要对齐的第二个数据框
    by.x = 1,        # 用于指定第一个数据框中的列名，默认为 1，表示第一列的列名。也可以直接输入列名，如 by.x = "OTU ID"
    by.y = 1,        # 用于指定第二个数据框中的列名，默认为 1，表示第一列的列名。也可以直接输入列名，如 by.y = "OTU ID"
    all.x = F,       # 是否保留左侧数据框的所有行？默认 FALSE
    all.y = F,       # 是否保留右侧数据框的所有行？默认 FALSE
    sort = F         # 是否重新排列？默认否
) {
  # 初始化列表
  result_list = NULL
  
  # 获取 tax_table 长度
  len_tax <- length(tax_table)
  
  # 进行对齐
  merged_data <- base::merge(x = tax_table, y = otu_table, 
                             by.x = by.x, by.y = by.y, 
                             all.x = all.x, all.y = all.y, sort = sort)
  
  # 如果使用了行名进行匹配，需要给 len_tax 加 1。因为会自动将行名加入到第 1 列，使得长度多了 1。
  if(by.x == "row.names") {
    len_tax <- len_tax + 1
  }
  
  # 获取更新后的 otu 表格和 tax 表格
  tax_table2 <- merged_data[, c(1:len_tax)]
  otu_table2 <- merged_data[, -c(2:len_tax)]
  
  
  # 如果使用了行名进行匹配，则将第一列还原成行名，并且移除
  if(by.x == "row.names") {
    # 重新设置行名
    rownames(otu_table2) <- otu_table2[, 1]
    rownames(tax_table2) <- tax_table2[, 1]
    # 移除第一列
    otu_table2 <- otu_table2[, -1]
    tax_table2 <- tax_table2[, -1]
  }
  
  
  result_list = list(otu = otu_table2, tax = tax_table2)
  
  return(result_list)
}






# 自定义数据抽平函数
data_rarefy <- function(file, 
                        id_col = 0,   # OTU_ID 列是第几列，默认为 0，则表示没有 OTU_ID 列，该数据已经为纯数字
                        
                        method = "vegan",    # 抽平方法
                        
                        seed = 123,          # 如果抽平方法设置为 phyloseq，则必须设置随机种子
                        replace = F,         # 默认关闭替代采样。开启可以加快抽平速度，但是会导致某些 OTU 抽平后的计数大于原始值
                        trimOTUs = T,        # 是否移除每个样本的计数为零的 OTU
                        
                        tax_table = NULL,    # 当 trimOTUs = T 时，可输入 tax_table 进行对齐，此时返回一个列表，包含 OTU 和 TAX。注意 tax 表的 OTU_ID 列与 otu 表要相同。
                        
                        write_file = TRUE,   # 是否保存抽平后的文件，默认：TRUE
                        file_name = "table"  # 保存文件名
                        ) {

  # 获取 OTU_ID 是第几列
  if(id_col > 0) {
    
    # 转换为 data.frame
    file <- as.data.frame(file)

    # 重命名行名
    rownames(file) <- file[, id_col]
    
    # 移除 OTU ID 列
    file <- file[, -id_col, drop = FALSE]
    
  } else {}  # 无 OTU_ID 列
  
  
  ## 判断每列是否为纯数字
  # sapply 函数用来使用某个方法来遍历每一列，检查是否还存在非数字列
  is_numeric <- sapply(
    file, function(col) { 
      all(grepl("^\\d+$", as.character(col)))
    }
  )
  # 存储判断结果
  is_numeric <- as.data.frame(is_numeric)
  
  # 如果所有列都是纯数字
  if (all(is_numeric)) {

  } else {
    # 找到不是纯数字的列
    non_numeric_cols <- which(!is_numeric)
    
    real_col <- non_numeric_cols
  
    # 如果 (!id_col == 0) 为 TRUE ，则将 non_numeric_cols + 1，因为多了一列 OTU_ID
    if(isTRUE(!id_col == 0)) {
      real_col <- non_numeric_cols + 1
    } 
    
    # 提示信息
    message(paste("Columns ", paste(real_col, collapse = ", "), " are not numeric.", sep = ""))
    
    cat("预览前 3 行：\n", sep = "")
    print(file[1:3, non_numeric_cols])  # 输出前 3 行进行预览
    
    stop("请重新检查数据后重试")
  }
  

  ##
  maxColSums <- max(colSums(file))  # 获取最大的列和
  minColSums <- min(colSums(file))  # 获取最小的列和
  
  # 将 method 转换为小写
  method <- tolower(method)
  
  if(method == "vegan") {
    # 调用 vegan 包 rrarefy 函数进行数据抽平
    otu_rarefy <- t(vegan::rrarefy(t(file), minColSums))
    
    # 转换成 data.frame
    otu_rarefy <- as.data.frame(otu_rarefy)
    
  } else if(method == "phyloseq") {
    
    # 设置随机种子
    set.seed(seed = seed)
    
    ##
    sue = 1231
    
    # 调用 phyloseq 包 otu_table 函数，将数据转化为 otu_table 格式
    otu_table <- phyloseq::otu_table(object = file, taxa_are_rows = T)
    
    # 调用 phyloseq 包 ?rarefy_even_depth 函数，进行数据抽平
    otu_table <- phyloseq::rarefy_even_depth(
      physeq = otu_table, 
      replace = replace,
      trimOTUs = trimOTUs, 
      verbose = T)
    
    # 提取数据表格
    otu_rarefy <- as.data.frame(otu_table@.Data)
    
  } else {
    stop("\"method\" parameter error, please enter \"method = vegan\"", 
         " or \"method = pholoseq\" and try again.\n", sep = "")
  }
  
  
  # 返回经过抽平后的表格
  cat("\033[0;32m", "Succeed!\n", 
      "Method: ", method, "\n", 
      "Colsums_Maximum: ", maxColSums, "\n",  
      "Colsums_Minimum: ", minColSums, "\n", 
      "All colsums -> ", minColSums, "\n", 
      "Data type: ", class(otu_rarefy), "\033[0m\n", sep = "")
  if(method == "phyloseq") {
    cat("\033[0;32m", "Seed: ", seed, "\033[0m\n", sep = "")
  }
  
  otu_rarefy <- cbind(OTU_ID = rownames(otu_rarefy), otu_rarefy)   # 将行名作为第一列
  colnames(otu_rarefy) <- c("#OTU ID", colnames(otu_rarefy)[-1])   # 重命名
  rownames(otu_rarefy) <- NULL  # 初始化行名
  
  ##
  # 当 method == "phyloseq"， 且 trimOTUs = TRUE 时，判断 tax_table 是否为 NULL
  # 若 tax_table == NULL，则不执行对齐
  # 若 tax_table != NULL, 则执行对齐

  merged_data <- NULL   # 初始化列表
  
  if(method == base::tolower("phyloseq") && isTRUE(trimOTUs)) {
    # tax_table 为空
    if(is.null(tax_table)) {
      
    } else {
      # tax_table 非空
      
      # 如果存在 OTU ID 列，即 id_col > 0
      if(id_col > 0) {
        merged_data <- align_otu_tax(tax_table = tax_table,   # tax 表格
                                      otu_table = otu_rarefy,  # otu 表格
                                      
                                      # 指定哪一列进行匹配
                                      by.x = 1,                # tax 的 #OTU ID
                                      by.y = 1,                # otu 的 #OTU ID
                                      
                                      # 右连接
                                      all.x = F, 
                                      all.y = T, 
                                      
                                      sort = F                 # 保持原来的排序
        )
        
      } else {
        # 如果不存在 OTU ID 列，即 id_col = 0
        # 行名就是 OTU ID
        
        
        merged_data <- align_otu_tax(tax_table = tax_table,   # tax 表格
                                      otu_table = otu_rarefy,  # otu 表格
                                      
                                      # 指定哪一列进行匹配
                                      by.x = "row.names",      # tax 的 #OTU ID
                                      by.y = 1,                # otu 的 #OTU ID
                                      
                                      # 右连接
                                      all.x = F, 
                                      all.y = T, 
                                      
                                      sort = F                 # 保持原来的排序
        )
      }

      # View(merged_data[[1]])
      # View(merged_data[[2]])
      
      ###
      if(isTRUE(write_file)) {
        
        # 文件名
        file_name_otu = paste0(file_name, "_rarefy_p.csv")
        file_name_tax = "tax_alignment.csv"
        
        otu_rarefy2 <- merged_data[[1]]
        tax_align2 <- merged_data[[2]]
        
        
        # id_col <= 0 ,则需要将行名转换成第一列，并将其列名设置为“# OTU ID”，再保存
        if(id_col <= 0) {
          otu_rarefy3 <- cbind(OTU_ID = rownames(otu_rarefy2), otu_rarefy2)  # 将行名作为第一列
          tax_align3 <- cbind(OTU_ID = rownames(tax_align2), tax_align2)     # 将行名作为第一列
          
          colnames(otu_rarefy3) <- c("#OTU ID", colnames(otu_rarefy3)[-1])   # 重命名
          colnames(tax_align3) <- c("#OTU ID", colnames(tax_align3)[-1])     # 重命名
          
          rownames(otu_rarefy3) <- NULL  # 初始化行名
          rownames(tax_align3) <- NULL   # 初始化行名
          
          # 调用 readr 包 write_excel_csv 函数，将数据保存为 CSV 文件
          readr::write_excel_csv(x = otu_rarefy3, file = file_name_otu)
          readr::write_excel_csv(x = tax_align3, file = file_name_tax)
          
          
          cat("\033[0;32m", "\nThe file \"", file_name_otu, " ,", file_name_tax, "\" has been saved to \n", 
              getwd(), "/", file_name_otu, "\n", 
              getwd(), "/", file_name_tax, "\033[0m\n", 
              sep = "")
          
          
          
          
        } else {
          # id_col > 0，直接保存
          # 调用 readr 包 write_excel_csv 函数，将数据保存为 CSV 文件
          readr::write_excel_csv(x = otu_rarefy2, file = file_name_otu)
          readr::write_excel_csv(x = tax_align2, file = file_name_tax)
          
          
          cat("\033[0;32m", "\nThe file \"", file_name_otu, " ,", file_name_tax, "\" has been saved to \n", 
              getwd(), "/", file_name_otu, "\n", 
              getwd(), "/", file_name_tax, "\033[0m\n", 
              sep = "")
        }
      }
      
      
      return(merged_data)
    }# tax_table 非空
  }
  
  
  
  
  if(isTRUE(write_file)) {
    # 文件名
    if(method == "vegan") {
      file_name2 = paste0(file_name, "_rarefy_v.csv")
      
    } else if(method == "phyloseq") {
      file_name2 = paste0(file_name, "_rarefy_p.csv")
    }
    
    # 调用 readr 包 write_excel_csv 函数，将数据保存为 CSV 文件
    readr::write_excel_csv(x = otu_rarefy, file = file_name2)
    
    cat("\033[0;32m", "\nThe file \"", file_name2, "\" has been saved to \n", 
        getwd(), "/", file_name2, "\033[0m\n", sep = "")
  }
  
  # id_col <= 0 ,则需要将第一列转换成行名，并将第一列移除，再返回结果
  if(id_col <= 0) {
    rownames(otu_rarefy) <- otu_rarefy[, 1]
    otu_rarefy <- otu_rarefy[, -1]
    return(otu_rarefy)
    
  } else {
    return(otu_rarefy)
  }
}

