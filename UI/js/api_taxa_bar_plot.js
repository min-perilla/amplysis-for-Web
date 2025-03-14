// 封装函数：调用物种堆叠图绘制的流程
async function drawTaxaBarPlot() {
    try {
        console.log("已提交信息：绘制物种堆叠图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const taxonomyData = sharedTaxonomyData;   // Tax
        const metadata = sharedMetadataData;       // Metadata

        // 获取其他参数
        const groupInformation1 = document.getElementById("species_stack_groupInformation1").value; // 获取实验分组1的值
        const groupInformation2 = document.getElementById("species_stack_groupInformation2").value; // 获取实验分组2的值
        const group2 = groupInformation2 === "无" ? "NULL" : groupInformation2;  // 如果是“无”，则转换为“NULL”

        const parallelInformation = document.getElementById("species_stack_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("species_stack_parallelMethods").value; // 获取平行样处理方法

        const classification = document.getElementById("species_stack_classification").value; // 获取分类等级的值
        const speciesCount = document.getElementById("species_stack_speciesCountInput").value; // 获取物种数量输入框的值

        const colorText = document.getElementById("species_stack_colorText").value; // 获取颜色文本框中显示的最终颜色值

        const titleName2 = document.getElementById("species_stack_titleName").value.trim(); // 获取大标题的名称
        const titleName = titleName2 === "" ? "NULL" : titleName2;  // 如果是“”，则转换为“NULL”
        const titleSize = document.getElementById("species_stack_titleSize").value; // 获取大标题的字号

        const chartType = document.getElementById("species_stack_chartType").value; // 获取堆叠图类型（相对丰度/绝对丰度）
        const barWidth = document.getElementById("species_stack_barWidth").value; // 获取图柱形宽度
        const gridLines = document.getElementById("species_stack_gridLines").value; // 获取网格线是否开启的值

        const xAxisName = document.getElementById("species_stack_xAxisName").value; // 获取X轴名称
        const xAxisSize = document.getElementById("species_stack_xAxisSize").value; // 获取X轴字号大小
        const xAxisScaleSize = document.getElementById("species_stack_xAxisScaleSize").value; // 获取X轴刻度字号大小
        const xAxisOrder = document.getElementById("species_stack_xAxisOrder").value; // 获取自定义X轴分组排序

        const yAxisName = document.getElementById("species_stack_yAxisName").value; // 获取Y轴名称
        const yAxisSize = document.getElementById("species_stack_yAxisSize").value; // 获取Y轴字号
        const yAxisScaleSize = document.getElementById("species_stack_yAxisScaleSize").value; // 获取X轴刻度字号大小

        const facetFontSize = document.getElementById("species_stack_facetFontSize").value; // 获取分面图字号
        const facetBgColor = document.getElementById("species_stack_facetBgColor").value; // 获取分面图背景色
        const facetOrder = document.getElementById("species_stack_facetOrder").value; // 获取分面图分组排序

        const legendName = document.getElementById("species_stack_legendName").value; // 获取图例标题名称
        const legendSize = document.getElementById("species_stack_legendSize").value; // 获取图例标题字号
        const legendTextSize = document.getElementById("species_stack_legendTextSize").value; // 获取图例正文字号
        const legendSizeValue = document.getElementById("species_stack_legendSizeValue").value; // 获取图例大小
        const legendTitleSpacing = document.getElementById("species_stack_legendTitleSpacing").value; // 获取图例标题间距
        const legendTextSpacing = document.getElementById("species_stack_legendTextSpacing").value; // 获取图例正文间距
        const legendColumns = document.getElementById("species_stack_legendColumns").value; // 获取图例列数

        const exportName = document.getElementById("species_stack_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("species_stack_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("species_stack_exportHeight").value; // 获取导出图像高度

        const exportFormats = [];
        const checkboxIds = [
            "species_stack_checkbox_PNG",
            "species_stack_checkbox_PDF",
            "species_stack_checkbox_JPG"
        ];
        checkboxIds.forEach(id => {
            const checkbox = document.getElementById(id);
            if (checkbox && checkbox.checked) {
                exportFormats.push(checkbox.value);
            }
        });

        const requestBody = {
            featureData,
            taxonomyData,
            metadata,
            groupInformation: {
                group1: groupInformation1,
                group2: group2,
            },
            parallel: {
                information: parallelInformation,
                parallel_method: parallelMethods,
            },
            classification: {
                tax_cla: classification,
                row_n: speciesCount,
            },
            colorSettings: {
                color_scheme: colorText,
            },
            title: {
                title: titleName,
                size_title: titleSize,
            },
            chart: {
                bar_type: chartType,
                bar_width: barWidth,
                grid_line: gridLines,
            },
            xAxis: {
                title_x: xAxisName,
                size_title_x: xAxisSize,
                size_x: xAxisScaleSize,
                custom_order: xAxisOrder,
            },
            yAxis: {
                title_y: yAxisName,
                size_title_y: yAxisSize,
                size_y: yAxisScaleSize,
            },
            facet: {
                size_title_facet: facetFontSize,
                color_bg_facet: facetBgColor,
                custom_order_F: facetOrder,
            },
            legend: {
                title_legend: legendName,
                size_title_legned: legendSize,
                size_legned: legendTextSize,
                size_point_legend: legendSizeValue,
                spacing_legend_title: legendTitleSpacing,
                spacing_legend_point: legendTextSpacing,
                legend_ncol: legendColumns,
            },

            exportSettings: {
                filename: exportName,
                file_width: exportWidth,
                file_height: exportHeight,
                formats: exportFormats,
            },
        };

        const response = await fetch(`${apiBaseURL}/taxa_bar_plot`, {
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
            (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) ||
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1)
        ) {
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) {
                console.warn("输入的 tax 表为空");
                showToast("Tax 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");
            }
        } else {
            const plotSpeciesStackDiv = document.getElementById("plot_species_stack");
            plotSpeciesStackDiv.innerHTML = result.svg;

            species_stack_svg = result.svg;
            console.log("species_stack_svg: ", species_stack_svg);

            const groups = sharedMetadataData.map(item => item.group);
            // console.log(groups);


            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度
            // console.log(`绘图函数重新赋值宽度: ${exportFile_Width}, 绘图函数重新赋值高度: ${exportFile_Height}`);
            


            showToast("物种堆叠图绘制成功！", "success", "bottom-right");
        }
    } catch (error) {
        console.error("调用 /taxa_bar_plot 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}

// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_species_stack").addEventListener("click", drawTaxaBarPlot);
