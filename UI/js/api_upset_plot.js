// 封装函数：调用 Upset 图绘制的流程

async function drawUpsetPlot() {
    try {
        console.log("已提交信息：绘制 Upset 图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const metadata = sharedMetadataData;       // Metadata

        // 获取其他参数
        // 分组
        const groupInformation1 = document.getElementById("upset_groupInformation1").value;     // 获取实验分组1的值
        const parallelInformation = document.getElementById("upset_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("upset_parallelMethods").value;         // 获取平行样处理方法

        // 配色
        const colorText = document.getElementById("upset_colorText").value;             // 获取颜色文本框中显示的最终颜色值
        const color_point = document.getElementById("upset_color_point").value;         // 交点配色
        const color_point_bg = document.getElementById("upset_color_point_bg").value;   // 交点背景色
        const color_bar = document.getElementById("upset_color_bar").value;             // 柱形图柱子配色

        // 属性
        const mb_ratio = document.getElementById("upset_mb_ratio").value   // 柱形图占比

        // 矩阵
        const title_matrix_x = document.getElementById("upset_title_matrix_x").value; // 矩阵图 X 轴名称
        const matrix_xAxisSize = document.getElementById("upset_matrix_xAxisSize").value; // 矩阵图 X 轴字号
        const matrix_yAxisSize = document.getElementById("upset_matrix_yAxisSize").value; // 矩阵图 Y 轴字号
        const matrix_labelAxisSize = document.getElementById("upset_matrix_labelAxisSize").value; // 矩阵图刻度标签大小
        const matrix_pointSize = document.getElementById("upset_matrix_pointSize").value; // 矩阵图点的大小
        const matrix_order = document.getElementById("upset_matrix_order").value; // 矩阵图排序顺序

        // 柱形图
        const title_bar_y = document.getElementById("upset_title_bar_y").value; // 柱形图 Y 轴名称
        const bar_yAxisSize = document.getElementById("upset_bar_yAxisSize").value; // 柱形图 Y 轴字号
        const size_bar_y = document.getElementById("upset_size_bar_y").value; // 柱形图刻度标签大小
        const size_bar_label = document.getElementById("upset_size_bar_label").value; // 柱形图刻度标签大小


        const bar_xAxisOrder = document.getElementById("upset_bar_xAxisOrder").value; // 柱形图 X 轴自定义排序
        const bar_barNum = document.getElementById("upset_bar_barNum").value; // 柱形图显示的柱子数量

        // 导出
        const exportName = document.getElementById("upset_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("upset_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("upset_exportHeight").value; // 获取导出图像高度

        const exportFormats = [];
        const checkboxIds = [
            "upset_checkbox_PNG",
            "upset_checkbox_PDF",
            "upset_checkbox_JPG"
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
            featureData,
            metadata,

            // 分组
            // 分组信息
            groupInformation: {
                group: groupInformation1
            },

            // 平行样
            parallel: {
                information: parallelInformation,
                parallel_method: parallelMethods
            },



            // 配色
            colorSettings: {
                color_matrix: colorText,         // 条形图配色
                color_point: color_point,        // 交点配色
                color_point_bg: color_point_bg,  // 交点背景色
                color_bar: color_bar             // 柱形图柱子配色
            },


            // 属性
            attribute: {
                mb_ratio: mb_ratio  // 柱形图占比
            },


            // 矩阵
            matrix: {
                title_matrix_x: title_matrix_x,  // 矩阵图 X 轴名称
                matrix_xAxisSize: matrix_xAxisSize,  // 矩阵图 X 轴字号
                matrix_yAxisSize: matrix_yAxisSize,  // 矩阵图 Y 轴字号
                matrix_labelAxisSize: matrix_labelAxisSize,  // 矩阵图刻度标签大小
                matrix_pointSize: matrix_pointSize,  // 矩阵图点的大小
                matrix_order: matrix_order  // 矩阵图排序顺序
            },


            // 柱形
            bar: {
                title_bar_y: title_bar_y,  // 柱形图 Y 轴名称
                bar_yAxisSize: bar_yAxisSize,  // 柱形图 Y 轴字号
                size_bar_y: size_bar_y,         // 柱形图刻度标签大小
                size_bar_label: size_bar_label, // bar 图柱子数字大小
                bar_xAxisOrder: bar_xAxisOrder,  // 柱形图 X 轴自定义排序
                bar_barNum: bar_barNum  // 柱形图显示的柱子数量
            },


            // 导出
            exportSettings: {
                filename: exportName,
                file_width: exportWidth,
                file_height: exportHeight,
                formats: exportFormats
            },
        };


        // 发送请求
        const response = await fetch(`${apiBaseURL}/upset_plot`, {
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



        // 判断 OTU 表或 metadata 表是否为空
        if (
            (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) ||  // OTU 表为空的情况
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1)  // metadata 表为空的情况
        ) {
            // 分别检查 OTU 表是否为空
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");  // 显示错误提示
            }
            // 分别检查 metadata 表是否为空
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");  // 显示错误提示
            }
        }
        // 若 metadata 表只有一项（但不为空的情况）
        else if (Array.isArray(result.metadata) && result.metadata.length === 1) {
            // 绘制 Upset 图
            const plotSpeciesStackDiv = document.getElementById("plot_upset");
            plotSpeciesStackDiv.innerHTML = result.svg;  // 将返回的 SVG 插入到 HTML 页面中

            // 提取 svg 数据存入全局变量
            upset_svg = result.svg;
            console.log("upset_svg: ", upset_svg);

            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Width = exportHeight;  // 存放导出文件的高度

            showToast("Upset 图绘制成功！", "success", "bottom-right");  // 显示成功提示
        }
        // 默认处理情况：绘制 Upset 图
        else {
            // 绘制 Upset 图
            const plotSpeciesStackDiv = document.getElementById("plot_upset");
            plotSpeciesStackDiv.innerHTML = result.svg;  // 将返回的 SVG 插入到 HTML 页面中

            upset_svg = result.svg;
            console.log("upset_svg: ", upset_svg);

            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度

            showToast("Upset 图绘制成功！", "success", "bottom-right");  // 显示成功提示
        }
    }
    catch (error) {
        // 捕获接口调用错误并给出提示
        console.error("调用 /upset_plot 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}

// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_upset").addEventListener("click", drawUpsetPlot);
