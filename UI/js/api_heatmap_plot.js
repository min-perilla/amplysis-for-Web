// 封装函数：调用热图绘制的流程
async function drawHeatmapPlot() {
    try {
        console.log("已提交信息：绘制热图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const taxonomyData = sharedTaxonomyData;   // Tax
        const metadata = sharedMetadataData;       // Metadata

        // 获取其他参数
        // 分组
        const groupInformation1 = document.getElementById("heatmap_groupInformation1").value; // 获取实验分组1的值
        const groupInformation2 = document.getElementById("heatmap_groupInformation2").value; // 获取实验分组2的值
        const group2 = groupInformation2 === "无" ? "NULL" : groupInformation2;  // 如果是“无”，则转换为“NULL”

        const parallelInformation = document.getElementById("heatmap_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("heatmap_parallelMethods").value; // 获取平行样处理方法

        const classification = document.getElementById("heatmap_classification").value; // 获取分类等级的值
        const speciesCount = document.getElementById("heatmap_speciesCountInput").value; // 获取物种数量输入框的值

        // 配色
        const colorText = document.getElementById("heatmap_colorText").value; // 获取颜色文本框中显示的最终颜色值

        // 方法
        const scale = document.getElementById("heatmap_scale").value; // 是否启动标准化
        const clustering_method = document.getElementById("heatmap_clustering_method").value; // 聚类算法

        // 聚类
        const custom_order = document.getElementById("heatmap_custom_order").value; // 用户输入的分组排序

        // 列聚类
        const cluster_cols = document.getElementById("heatmap_clustering_cols").value; // 是否启动列聚类
        const clustering_distance_cols = document.getElementById("heatmap_clustering_distance_cols").value; // 列聚类的距离度量
        const cutree_cols = document.getElementById("heatmap_cutree_cols").value; // 列簇数量

        // 行聚类
        const cluster_rows = document.getElementById("heatmap_clustering_rows").value; // 是否启动行聚类
        const clustering_distance_rows = document.getElementById("heatmap_clustering_distance_rows").value; // 行聚类的距离度量

        // 树高
        const treeheight_row = document.getElementById("heatmap_treeheight_row").value; // 行聚类树高度
        const treeheight_col = document.getElementById("heatmap_treeheight_col").value; // 列聚类树高度

        // 属性
        const title = document.getElementById("heatmap_titleName").value; // 大标题名称

        // 字体
        const fontsize = document.getElementById("heatmap_fontsize").value; // 热图基本字体大小
        const fontsize_row = document.getElementById("heatmap_fontsize_row").value; // 行标题字号
        const fontsize_col = document.getElementById("heatmap_fontsize_col").value; // 列标题字号
        const row_fontface_italic = document.getElementById("heatmap_row_fontface_italic").value; // 行标题斜体
        const angle_col = document.getElementById("heatmap_angle_col").value; // 列标题旋转角度

        // 标签
        const display_numbers = document.getElementById("heatmap_display_numbers").value; // 是否显示单元格数字标签
        const number_format = document.getElementById("heatmap_number_format").value; // 单元格数字的小数位数
        const number_color = document.getElementById("heatmap_number_color").value; // 单元格数字标签颜色

        // 图例
        const legend_breaks = document.getElementById("heatmap_legend_breaks").value; // 图例范围（断点）
        const legend_labels = document.getElementById("heatmap_legend_labels").value; // 图例断点的标签

        // 文件
        const exportName = document.getElementById("heatmap_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("heatmap_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("heatmap_exportHeight").value; // 获取导出图像高度
        // 导出文件格式
        const exportFormats = [];
        const checkboxIds = [
            "heatmap_checkbox_PNG",
            "heatmap_checkbox_PDF",
            "heatmap_checkbox_JPG"
        ];
        checkboxIds.forEach(id => {
            const checkbox = document.getElementById(id);
            if (checkbox && checkbox.checked) {
                exportFormats.push(checkbox.value);
            }
        });


        // 构建请求体
        const requestBody = {
            // OTU 数据
            featureData,   // OTU 数据，通常用于表示物种或基因的丰度信息

            // Taxonomy 数据
            taxonomyData,  // 分类信息，包含物种的分类层级信息（如属、科、目等）

            // Metadata 数据
            metadata,      // 样本的元数据，通常包括样本的各种描述信息，如实验条件等

            // 分组信息
            groupInformation: {
                group1: groupInformation1,  // 实验分组1，用户选择的分组信息
                group2: group2,             // 实验分组2，用户选择的分组信息，如果选择了“无”则转为“NULL”
            },

            // 平行样本处理信息
            parallel: {
                information: parallelInformation,  // 平行样标识，描述平行样本的标识
                parallel_method: parallelMethods,  // 平行样本的处理方法，描述如何处理平行样
            },

            // 分类信息
            classification: {
                tax_cla: classification,  // 分类等级，如门、纲、目等
                row_n: speciesCount,      // 物种数量，限制数据中使用的物种数量
            },

            // 配色设置
            colorSettings: {
                color_scheme: colorText,  // 最终选定的配色方案，通常是色带或其他颜色配置
            },

            // 方法
            methods: {
                scale: scale,  // 是否进行数据标准化，布尔值
                clustering_method: clustering_method  // 聚类算法
            },

            // 聚类相关设置
            clustering: {
                custom_order: custom_order,  // 是否进行分组排序，布尔值

                // 列聚类设置
                cluster_cols: cluster_cols,  // 是否启动列聚类，布尔值
                clustering_distance_cols: clustering_distance_cols,  // 列聚类的距离度量方法
                cutree_cols: cutree_cols,  // 列簇数量

                // 行聚类设置
                cluster_rows: cluster_rows,  // 是否启动行聚类，布尔值
                clustering_distance_rows: clustering_distance_rows,  // 行聚类的距离度量方法
            },

            // 树状图高度设置
            treeheight: {
                row: treeheight_row,  // 行聚类树的高度
                col: treeheight_col,  // 列聚类树的高度
            },

            // 图表标题
            titleSettings: {
                title: title || "NULL",  // 大标题名称，如果为空则为“NULL”
            },

            // 字体设置
            fontSettings: {
                fontsize: fontsize,  // 基本字体大小
                fontsize_row: fontsize_row,  // 行标题字号
                fontsize_col: fontsize_col,  // 列标题字号
                row_fontface_italic: row_fontface_italic,  // 行标题是否为斜体，布尔值
                angle_col: angle_col,  // 列标题旋转角度
            },

            // 标签设置
            labelSettings: {
                display_numbers: display_numbers,  // 是否显示单元格数字标签，布尔值
                number_format: number_format,  // 数字格式，小数位数等
                number_color: number_color,  // 单元格数字标签颜色
            },

            // 图例设置
            legendSettings: {
                legend_breaks: legend_breaks,  // 图例断点
                legend_labels: legend_labels,  // 图例标签
            },

            // 导出设置
            exportSettings: {
                filename: exportName,  // 导出文件名
                file_width: exportWidth,  // 导出文件宽度
                file_height: exportHeight,  // 导出文件高度
                formats: exportFormats,  // 导出文件格式，支持多种格式如 PNG, PDF, JPG
            },
        };


        // 发送请求
        const response = await fetch(`${apiBaseURL}/heatmap_plot`, {
            method: "POST",  // 使用 POST 请求
            headers: {
                "Content-Type": "application/json",  // 设置请求头为 JSON 类型
            },
            body: JSON.stringify(requestBody)  // 将请求体转换为 JSON 字符串
        });

        // 检查请求是否成功
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);  // 请求失败时抛出错误
        }

        // 解析响应数据
        const result = await response.json();
        console.log("后端返回结果：", result);  // 输出后端返回的结果

        // 检查返回的结果中是否包含无效数据（-1）
        if (
            (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) ||
            (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) ||
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1)
        ) {
            // 针对每种无效数据类型（OTU, Tax, Metadata）进行提示
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");  // 提示用户 OTU 表为空
            }
            if (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) {
                console.warn("输入的 tax 表为空");
                showToast("Tax 表为空！", "error", "bottom-right");  // 提示用户 Tax 表为空
            }
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");  // 提示用户 Metadata 文件为空
            }
        } else {
            // 若结果有效，则将返回的热图 SVG 插入到页面中
            const plotSpeciesStackDiv = document.getElementById("plot_heatmap");
            plotSpeciesStackDiv.innerHTML = result.svg;  // 设置绘图容器的 HTML 内容为返回的 SVG

            heatmap_svg = result.svg;  // 将返回的 SVG 存储到全局变量中
            console.log("heatmap_svg: ", heatmap_svg);  // 输出保存的 SVG 数据

            // 获取元数据中的分组信息
            const groups = sharedMetadataData.map(item => item.group);
            // console.log(groups);  // 可选：打印分组信息，用于调试


            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度
            // console.log(`绘图函数重新赋值宽度: ${exportFile_Width}, 绘图函数重新赋值高度: ${exportFile_Height}`);  // 可选：输出宽高信息用于调试

            // 提示用户热图绘制成功
            showToast("热图绘制成功！", "success", "bottom-right");
        }

        // 错误捕获，处理请求过程中发生的任何异常
    } catch (error) {
        console.error("调用 /heatmap_plot 接口失败：", error);  // 输出错误信息
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");  // 提示用户接口调用失败
    }
}

// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_heatmap").addEventListener("click", drawHeatmapPlot);
