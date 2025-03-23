# start.R
# 2025-03-23

rm(list = ls())

# 记录原始库路径
original_libpaths <- .libPaths()

# 设置工作目录
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 确保 R 优先从本地 library 目录加载包
.libPaths(c(file.path(getwd(), "library"), .libPaths()))

# 启动 UI
browseURL("UI/index.html")

# 启动 API
pr <- plumber::plumb("API/api.R")
pr$run(port = 8000)

# 恢复原始的库路径
.libPaths(original_libpaths)
