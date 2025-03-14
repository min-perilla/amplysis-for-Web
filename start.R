# start.R

# 安装 R 包
if (!requireNamespace("plumber", quietly = TRUE)) {
  install.packages("plumber")
}

# 加载 R 包
library(plumber)

# 设置工作目录
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
cat(getwd())

# 启动 UI
browseURL("UI/index.html")

# 启动 API
pr <- plumber::plumb("API/api.R")
pr$run(port = 8000)
