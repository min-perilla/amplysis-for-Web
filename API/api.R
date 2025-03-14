# api.R

if (!requireNamespace("plumber", quietly = TRUE)) {
  install.packages("plumber")
}

library(plumber)


# 20250225
# API 元数据
#* @apiTitle amplysis for Web
#* @apiDescription This is an API "amplysis for Web" created using Plumber.
#* @apiVersion 1.0.0


# ------------------------------------------------------------------------------
# 定义 CORS 的钩子函数
cors_hook <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*") # 允许所有来源
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS") # 允许的方法
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization") # 允许的请求头
  if (req$REQUEST_METHOD == "OPTIONS") { # 处理预检请求
    res$status <- 200
    return(list(message = "CORS preflight"))
  }
  plumber::forward()
}

# 过滤器：应用 CORS 设置
#' @filter cors
cors_hook




# ------------------------------------------------------------------------------
# 定义 API 路由
source("./Rfunction/api_data_rarefy.R")
# R函数1
# “数据预处理”界面-“OTU数据抽平”
# 数据抽平函数
#' @post /data_rarefy
#' 
#' @param req 前端数据请求
#' 
function(req) {
  result = api_data_rarefy(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_tax_separate.R")
# R函数2
# “数据预处理”界面-“tax表分列”
# 数据抽平函数
#' @post /tax_separate
#' 
#' @param req 前端数据请求
function(req) {
  result = api_tax_separate(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_tax_trim_prefix.R")
# R函数3
# “数据预处理”界面-“tax表去前缀”
# 数据抽平函数
#' @post /tax_trim_prefix
#' 
#' @param req 前端数据请求
function(req) {
  result = api_tax_trim_prefix(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_tax_names_repair.R")
# R函数4
# “数据预处理”界面-“tax表信息修复”
# 信息修复函数
#' @post /tax_names_repair
#' 
#' @param req 前端数据请求
function(req) {
  result = api_tax_names_repair(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_taxa_bar_plot.R")
# R函数5
# “物种堆叠图”界面
# 物种堆叠图函数
#' @post /taxa_bar_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_taxa_bar_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
#' source("./Rfunction/api_chord_plot.R")
#' # R函数6
#' # “弦图”界面
#' # 弦图函数
#' #' @post /chord_plot
#' #'
#' #' @param req 前端数据请求
#' function(req) {
#'   result = api_chord_plot(req)
#'   return(result)
#' }




# ------------------------------------------------------------------------------
source("./Rfunction/api_venn_plot.R")
# R函数7
# “Venn 图”界面
# Venn 图函数
#' @post /venn_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_venn_plot(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_upset_plot.R")
# R函数8
# “Upset 图”界面
# Upset 图函数
#' @post /upset_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_upset_plot(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_alpha_plot.R")
# R函数9
# “alpha 图”界面
# alpha 图函数
#' @post /alpha_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_alpha_plot(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_pca_plot.R")
# R函数10
# “PCA 图”界面
# PCA 图函数
#' @post /pca_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_pca_plot(req)
  return(result)
}




# ------------------------------------------------------------------------------
source("./Rfunction/api_pcoa_plot.R")
# R函数11
# “PCoA 图”界面
# PCoA 图函数
#' @post /pcoa_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_pcoa_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
source("./Rfunction/api_nmds_plot.R")
# R函数12
# “NMDS 图”界面
# NMDS 图函数
#' @post /nmds_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_nmds_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
source("./Rfunction/api_rda_plot.R")
# R函数13
# “RDA 图”界面
# RDA 图函数
#' @post /RDA_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_rda_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
source("./Rfunction/api_cca_plot.R")
# R函数14
# “CCA 图”界面
# CCA 图函数
#' @post /CCA_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_cca_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
source("./Rfunction/api_heatmap_plot.R")
# R函数15
# “热图”界面
# 热图函数
#' @post /heatmap_plot
#'
#' @param req 前端数据请求
function(req) {
  result = api_heatmap_plot(req)
  return(result)
}




#' # ------------------------------------------------------------------------------
source("./Rfunction/api_network.R")
# R函数16
# 共现性网络分析
# 网络分析函数
#' @post /network
#'
#' @param req 前端数据请求
function(req) {
  result = api_network(req)
  return(result)
}
