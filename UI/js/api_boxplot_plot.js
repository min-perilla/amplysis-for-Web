// 封装函数：调用 boxplot 图绘制的流程
async function drawBoxplotPlot() {
    try {
        console.log("已提交信息：绘制 boxplot 图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const metadata = sharedMetadataData;       // Metadata
        const tree = sharedTreeData;               // 系统发育树

        // 获取其他参数
        // 分组
        const groupInformation1 = document.getElementById("boxplot_groupInformation1").value; // 获取实验分组1的值
        const parallelInformation = document.getElementById("boxplot_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("boxplot_parallelMethods").value; // 获取平行样处理方法

        // 配色
        const colorText = document.getElementById("boxplot_colorText").value; // 最终颜色文本框

        // 方法
        const comparisons = document.getElementById("boxplot_comparisons").value; // 获取多重比较方法

        // 属性
        // 大标题
        // const titleName = document.getElementById("boxplot_titleName").value; // 获取大标题名称
        const titleSize = document.getElementById("boxplot_titleSize").value; // 获取大标题字号

        // 图形
        const size_point = document.getElementById("boxplot_size_point").value; // 获取点大小
        const size_differ = document.getElementById("boxplot_size_differ").value; // 获取显著性标记大小

        // 误差线
        const errorbar_width = document.getElementById("boxplot_errorbar_width").value; // 获取误差线上下横线的宽度
        const errorbar_linewidth = document.getElementById("boxplot_errorbar_linewidth").value; // 获取误差线竖线的宽度

        // X 轴
        const title_x = document.getElementById("boxplot_title_x").value; // 获取 X 轴名称
        const size_title_x = document.getElementById("boxplot_size_title_x").value; // 获取 X 轴标题字号
        const size_x = document.getElementById("boxplot_size_x").value; // 获取 X 轴刻度字号

        // X 轴自定义排序
        const custom_order = document.getElementById("boxplot_custom_order").value; // 获取 X 轴自定义排序
        const group1Auto = document.getElementById("boxplot_group1Auto").innerText; // 已识别到的“分组 1”各分组

        // Y 轴
        const title_y = document.getElementById("boxplot_title_y").value; // 获取 Y 轴名称
        const size_title_y = document.getElementById("boxplot_size_title_y").value; // 获取 Y 轴标题字号
        const size_y = document.getElementById("boxplot_size_y").value; // 获取 Y 轴刻度字号

        // 导出
        const exportName = document.getElementById("boxplot_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("boxplot_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("boxplot_exportHeight").value; // 获取导出图像高度

        const exportFormats = [];
        const checkboxIds = [
            "boxplot_checkbox_PNG",
            "boxplot_checkbox_PDF",
            "boxplot_checkbox_JPG"
        ];
        checkboxIds.forEach(id => {
            const checkbox = document.getElementById(id);
            if (checkbox && checkbox.checked) {
                exportFormats.push(checkbox.value);
            }
        });


        // 构建请求体
        const requestBody = {
            // 数据
            featureData,  // OTU 数据
            metadata,     // Metadata 数据
            tree,         // 系统发育树数据

            // 分组信息
            groupInformation: {
                group: groupInformation1 // 实验分组 1
            },

            // 平行样
            parallel: {
                information: parallelInformation,  // 平行样标识
                parallel_method: parallelMethods   // 平行样处理方法
            },

            // 颜色信息
            color: {
                color_scheme: colorText // 最终颜色方案
            },

            // 统计分析方法
            methods: {
                comparisons // 多重比较方法
            },

            // 图形属性
            attributes: {
                // 大标题
                title: {
                    // name: titleName,  // 大标题名称
                    size: titleSize   // 大标题字号
                },

                // 图形设置
                plot: {
                    size_point,  // 点大小
                    size_differ  // 显著性标记大小
                },

                // 误差线
                errorbar: {
                    width: errorbar_width,        // 误差线上下横线宽度
                    line_width: errorbar_linewidth // 误差线竖线宽度
                }
            },

            // 坐标轴
            axis: {
                // X 轴
                x: {
                    title: title_x,       // X 轴名称
                    title_size: size_title_x, // X 轴标题字号
                    tick_size: size_x      // X 轴刻度字号
                },

                // X 轴自定义排序
                x_order: {
                    custom_order, // 用户输入的自定义排序
                    detected_groups: group1Auto // 自动识别到的分组 1 各分组
                },

                // Y 轴
                y: {
                    title: title_y,       // Y 轴名称
                    title_size: size_title_y, // Y 轴标题字号
                    tick_size: size_y      // Y 轴刻度字号
                }
            },

            // 导出信息
            exportSettings: {
                filename: exportName,     // 导出文件名称
                file_width: exportWidth,  // 导出图像宽度
                file_height: exportHeight, // 导出图像高度
                formats: exportFormats    // 导出格式列表
            }
        };


        // 发送请求
        const response = await fetch(`${apiBaseURL}/alpha_plot`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        console.log("后端返回结果：", result);



        if (
            (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) ||
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1)
        ) {
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");
            }
        } else if (Array.isArray(result.metadata) && result.metadata.length === 1) {

            // 定义 ID 对应关系
            const svgMap = {
                shannon: "plot_boxplot_shannon",
                simpson: "plot_boxplot_simpson",
                chao1: "plot_boxplot_chao1",
                ace: "plot_boxplot_ace",
                pielou: "plot_boxplot_pielou",
                goods_coverage: "plot_boxplot_coverage",
                pd: "plot_boxplot_pd"
            };

            // 遍历返回的 SVG 数据，并更新 HTML 和全局变量
            Object.entries(result.svg).forEach(([key, svgContent]) => {
                const divId = svgMap[key]; // 获取对应的 div ID
                if (divId) {
                    document.getElementById(divId).innerHTML = svgContent; // 插入 SVG
                }
                boxplot_svg[key] = svgContent; // 存储 SVG 数据
            });

            // 额外检查 PD 图像是否为空
            console.log("PD SVG Data:", boxplot_svg.pd);

            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度

            showToast("箱线图绘制成功！", "success", "bottom-right");

        }
    } catch (error) {
        console.error("调用 /alpha_plot 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}


// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_boxplot").addEventListener("click", drawBoxplotPlot);
