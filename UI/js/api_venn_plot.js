// 封装函数：调用 Venn 图绘制的流程
async function drawVennPlot() {
    try {
        console.log("已提交信息：绘制 Venn 图");

        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const metadata = sharedMetadataData;       // Metadata

        // 获取其他参数
        const groupInformation1 = document.getElementById("venn_groupInformation1").value; // 获取实验分组1的值
        const parallelInformation = document.getElementById("venn_parallelInformation").value; // 获取平行样标识
        const parallelMethods = document.getElementById("venn_parallelMethods").value; // 获取平行样处理方法

        const colorText = document.getElementById("venn_colorText").value; // 获取颜色文本框中显示的最终颜色值

        const showPercentage = document.getElementById("venn_showPercentage").value  // 获取是否显示百分比选项
        const percentDigits = document.getElementById("venn_percentDigits").value    // 获取显示小数点位数

        const datasetTitleSize = document.getElementById("venn_datasetTitleSize").value  // 获取数据集标题字号大小
        const plotFontSize = document.getElementById("venn_plotFontSize").value  // 获取图内字体字号

        const exportName = document.getElementById("venn_exportName").value; // 获取导出文件名称
        const exportWidth = document.getElementById("venn_exportWidth").value; // 获取导出图像宽度
        const exportHeight = document.getElementById("venn_exportHeight").value; // 获取导出图像高度

        const exportFormats = [];
        const checkboxIds = [
            "venn_checkbox_PNG",
            "venn_checkbox_PDF",
            "venn_checkbox_JPG"
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
                color_scheme: colorText
            },

            // 百分比
            percentage: {
                show_percentage: showPercentage,
                digits: percentDigits
            },

            // 字号
            size: {
                size_set_name: datasetTitleSize,
                size_text: plotFontSize
            },

            exportSettings: {
                filename: exportName,
                file_width: exportWidth,
                file_height: exportHeight,
                formats: exportFormats
            },
        };


        // 发送请求
        const response = await fetch(`${apiBaseURL}/venn_plot`, {
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
            // 检查 metadata 的值
            const metadataValue = result.metadata[0];
            if (metadataValue === -2) {
                console.warn("分组数量少于 2");
                showToast("分组数量小于 2", "error", "bottom-right");
            } else if (metadataValue === -4) {
                console.warn("分组数量超过 4");
                showToast("分组数量超过 4", "error", "bottom-right");
            } else {
                // 绘制 Venn 图
                const plotSpeciesStackDiv = document.getElementById("plot_venn");
                plotSpeciesStackDiv.innerHTML = result.svg;
    
                venn_svg = result.svg;
                console.log("venn_svg: ", venn_svg);
    
                // 将图像宽度和高度赋值到全局变量
                exportFile_Width = exportWidth;    // 存放导出文件的宽度
                exportFile_Width = exportHeight;  // 存放导出文件的高度
    
                showToast("Venn 图绘制成功！", "success", "bottom-right");
            }
        } else {
            // 绘制 Venn 图
            const plotSpeciesStackDiv = document.getElementById("plot_venn");
            plotSpeciesStackDiv.innerHTML = result.svg;
    
            venn_svg = result.svg;
            console.log("venn_svg: ", venn_svg);
    
            // 将图像宽度和高度赋值到全局变量
            exportFile_Width = exportWidth;    // 存放导出文件的宽度
            exportFile_Height = exportHeight;  // 存放导出文件的高度
    
            showToast("Venn 图绘制成功！", "success", "bottom-right");
        }
    } catch (error) {
        console.error("调用 /venn_plot 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}

// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_venn").addEventListener("click", drawVennPlot);
