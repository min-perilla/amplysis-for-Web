// 封装函数：调用 RDA 图绘制的流程
async function drawRdaPlot() {
    try {
        console.log("已提交信息：绘制 RDA 图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const metadata = sharedMetadataData;       // Metadata
        const env = sharedEnvData;                 // Env

        // 获取其他参数
        const groupInformation1 = document.getElementById("rda_groupInformation1").value; // 获取实验分组1的值
        const parallelInformation = document.getElementById("rda_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("rda_parallelMethods").value; // 获取平行样处理方法

        const ellipse_type = document.getElementById("rda_ellipse_type").value; // 获取置信椭圆计算方法

        const colorText = document.getElementById("rda_colorText").value; // 获取颜色文本框中显示的最终颜色值

        const titleName = document.getElementById("rda_titleName").value  // 大标题名称
        const titleSize = document.getElementById("rda_titleSize").value  //大标题字号
        const subTitleName = document.getElementById("rda_subTitleName").value  // 副标题名称
        const subTitleSize = document.getElementById("rda_subTitleSize").value  // 副标题字号
        const showLabel = document.getElementById("rda_showLabel").value  // 显示数字标签
        const labelSize = document.getElementById("rda_labelSize").value  // 数字标签字号
        const pointSize = document.getElementById("rda_pointSize").value  // 点大小

        const xAxisTitleSize = document.getElementById("rda_xAxisTitleSize").value  // X 轴标题字号
        const xAxisSize = document.getElementById("rda_xAxisSize").value  // X 轴刻度字号

        const yAxisTitleSize = document.getElementById("rda_yAxisTitleSize").value  // Y 轴标题字号
        const yAxisSize = document.getElementById("rda_yAxisSize").value  // Y 轴刻度字号

        const legendName = document.getElementById("rda_legendName").value;  // 图例名称
        const legendSize = document.getElementById("rda_legendSize").value;  // 图例标题字号
        const legendTextSize = document.getElementById("rda_legendTextSize").value;  // 正文字号
        const legendSizeValue = document.getElementById("rda_legendSizeValue").value;  // 图例大小
        const legendTitleSpacing = document.getElementById("rda_legendTitleSpacing").value;  // 标题间距
        const legendTextSpacing = document.getElementById("rda_legendTextSpacing").value;  // 正文间距
        const legendColumns = document.getElementById("rda_legendColumns").value;  // 图例列数
        const legendOrder = document.getElementById("rda_legendOrder").value;  // 自定义排序文本区域

        const exportName = document.getElementById("rda_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("rda_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("rda_exportHeight").value; // 获取导出图像高度

        const exportFormats = [];
        const checkboxIds = [
            "rda_checkbox_PNG",
            "rda_checkbox_PDF",
            "rda_checkbox_JPG"
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
            env,

            // 分组信息
            groupInformation: {
                group: groupInformation1
            },

            // 平行样
            parallel: {
                information: parallelInformation,  // 平行样标识
                parallel_method: parallelMethods
            },

            // 颜色信息
            color: {
                color_scheme: colorText
            },

            // 方法
            methods: {
                ellipse_type: ellipse_type
            },

            // 标题信息
            title: {
                title: titleName,
                size_title: titleSize
            },

            // 副标题信息
            subTitle: {
                title_sub: subTitleName,
                size_title_sub: subTitleSize
            },

            // 数字标签信息
            label: {
                label_is: showLabel,
                size_label: labelSize
            },

            // 点大小
            size_point: pointSize,

            // 坐标轴信息
            xAxis: {
                size_title_x: xAxisTitleSize,
                size_x: xAxisSize
            },

            yAxis: {
                size_title_y: yAxisTitleSize,
                size_y: yAxisSize
            },

            // 图例信息
            legend: {
                title_legend: legendName,
                size_title_legend: legendSize,
                size_legend: legendTextSize,
                size_point_legend: legendSizeValue,
                spacing_legend_point: legendTextSpacing,
                spacing_legend_title: legendTitleSpacing,
                legend_ncol: legendColumns,
                custom_order: legendOrder
            },

            // 导出信息
            exportSettings: {
                filename: exportName,
                file_width: exportWidth,
                file_height: exportHeight,
                formats: exportFormats,
            },
        };



        // 发送请求
        const response = await fetch(`${apiBaseURL}/RDA_plot`, {
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
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) ||
            (Array.isArray(result.env) && result.env.length === 1 && result.env[0] === -1)
        ) {
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.env) && result.env.length === 1 && result.env[0] === -1) {
                console.warn("输入的 env 表为空");
                showToast("Env file 为空！", "error", "bottom-right");
            }
        } else if (Array.isArray(result.metadata) && result.metadata.length === 1) {
            // 检查 metadata 的值
            const metadataValue = result.metadata[0];

            // 绘制 RDA 图
            const plotSpeciesStackDiv = document.getElementById("plot_rda");
            plotSpeciesStackDiv.innerHTML = result.svg;

            rda_svg = result.svg;
            console.log("rda_svg: ", rda_svg);

            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度

            showToast("RDA 图绘制成功！", "success", "bottom-right");

        }
    } catch (error) {
        console.error("调用 /RDA_plot 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}


// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_rda").addEventListener("click", drawRdaPlot);
