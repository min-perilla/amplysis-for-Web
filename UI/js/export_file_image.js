/**
 * 通用的导出设置函数，集成了宽度和高度变化的检测，自动绘图再导出
 * 
 * @param {string} containerId - 包含导出控件的容器 ID。
 * @param {object} ids - 包含导出控件各子元素 ID 的映射对象，包括：
 *    - fileNameId: 文件名输入框 ID
 *    - fileTypeContainerId: 文件格式复选框容器 ID
 *    - widthId: 图像宽度输入框 ID
 *    - heightId: 图像高度输入框 ID
 *    - buttonId: 导出按钮 ID
 * @param {function} getSvgData - 获取 SVG 数据的回调函数，通常返回一个 SVG 元素或 SVG 字符串。
 * @param {function} plotFunction - 绘图函数，用于绘制当前需要导出的图表或图像。
 * @param {function} updateDimensions - 更新全局宽高变量的回调函数
 * @param {number} DPI - 图像分辨率，默认为 300，通常为图像导出时的质量控制参数，单位为 DPI。
 */
function setupExportWithPlot(containerId, ids, getSvgData, plotFunction, updateDimensions, DPI = 300) {
    const container = document.getElementById(containerId);
    if (!container) {
        console.error(`未找到容器：${containerId}`);
        return;
    }

    const { fileNameId, fileTypeContainerId, widthId, heightId, buttonId } = ids;

    const exportButton = container.querySelector(`#${buttonId}`);
    if (!exportButton) {
        console.error(`容器 ${containerId} 中未找到导出按钮：#${buttonId}`);
        return;
    }

    const widthInput = document.getElementById(widthId);
    const heightInput = document.getElementById(heightId);

    exportButton.addEventListener("click", async () => {
        const currentWidth = parseInt(widthInput.value);
        const currentHeight = parseInt(heightInput.value);

        if (isNaN(currentWidth) || isNaN(currentHeight)) {
            showToast("宽度和高度不能为空！", "warning");
            console.error("检测到空的宽度或高度输入");
            return;
        }

        // 检测宽高是否变化，若变化则重新绘图
        if (currentWidth !== exportFile_Width || currentHeight !== exportFile_Height) {
            console.log("检测到宽度或高度变化，重新绘图...");
            await plotFunction();
            updateDimensions(currentWidth, currentHeight);
        }

        const svgData = getSvgData();
        if (!svgData || Object.keys(svgData).length === 0) {
            showToast("导出文件失败！", "error");
            console.error("无效的 SVG 数据：", svgData);
            return;
        }

        const fileName = container.querySelector(`#${fileNameId}`).value.trim() || "export";
        const formats = Array.from(container.querySelectorAll(`#${fileTypeContainerId} input[type="checkbox"]:checked`))
            .map((checkbox) => checkbox.value);

        if (formats.length === 0) {
            showToast("请选择至少一个导出文件格式！", "warning");
            return;
        }

        // 记录每种格式的成功与失败情况
        const formatStatus = formats.reduce((status, format) => {
            status[format] = { success: true, failedKeys: [] };
            return status;
        }, {});

        let pendingExports = 0;

        Object.entries(svgData).forEach(([key, svg]) => {
            if (!svg) {
                console.warn(`${key} 的数据为空，跳过导出！`);
                return;
            }

            key = String(key).replace(/_0$/, "");

            formats.forEach((format) => {
                pendingExports++;
                // 修改这里，确保没有多余的后缀
                const finalFileName = key && key!== "0"? `${fileName}_${key}` : fileName; 
                
                exportSVG(svg, format, finalFileName, currentWidth, currentHeight, DPI)
                    .then((result) => {
                        if (!result.success) {
                            formatStatus[format].success = false;
                            formatStatus[format].failedKeys.push(key);
                        }
                    })
                    .catch((error) => {
                        formatStatus[format].success = false;
                        formatStatus[format].failedKeys.push(key);
                        console.error(`导出 ${key} 的 ${format} 文件失败：`, error);
                    })
                    .finally(() => {
                        pendingExports--;
                        if (pendingExports === 0) {
                            formats.forEach((format) => {
                                const status = formatStatus[format];
                                if (status.success) {
                                    showToast(`${format} 文件导出成功！`, "success");
                                } else {
                                    const failedKeys = status.failedKeys.join(", ");
                                    showToast(`导出 ${format} 文件失败：${failedKeys}`, "error");
                                }
                            });
                        }
                    });
            });
            
        });
    });
}

/**
 * 导出SVG文件的函数
 * @param {string} svgData - SVG数据
 * @param {string} format - 文件格式（svg, png, jpg, pdf）
 * @param {string} fileName - 文件名称
 * @param {number} width - 导出图像宽度
 * @param {number} height - 导出图像高度
 * @param {number} DPI - 图像分辨率（每英寸像素数）
 * @returns {Promise<object>} - 返回导出操作的结果对象
 */
async function exportSVG(svgData, format, fileName, width, height, DPI = 300) {
    try {
        const blob = new Blob([svgData], { type: 'image/svg+xml' });
        const url = URL.createObjectURL(blob);

        const a = document.createElement('a');
        a.href = url;
        a.download = fileName; 

        if (format === "png" || format === "jpg") {
            return new Promise((resolve) => {
                const img = new Image();
                img.onload = () => {
                    const canvas = document.createElement("canvas");
                    const pixelWidth = Math.round(width * DPI);
                    const pixelHeight = Math.round(height * DPI);
                    canvas.width = pixelWidth;
                    canvas.height = pixelHeight;
                    const ctx = canvas.getContext("2d");
                    ctx.drawImage(img, 0, 0, pixelWidth, pixelHeight);

                    if (format === "png") {
                        canvas.toBlob((blob) => {
                            if (!blob) {
                                resolve({ success: false });
                                return;
                            }
                            const imgUrl = URL.createObjectURL(blob);
                            a.href = imgUrl;
                            a.download = fileName; 
                            a.click();
                            URL.revokeObjectURL(imgUrl);
                            resolve({ success: true });
                        }, "image/png");
                    } else if (format === "jpg") {
                        // 明确指定 MIME 类型为 image/jpeg 并设置质量参数
                        canvas.toBlob((blob) => {
                            if (!blob) {
                                resolve({ success: false });
                                return;
                            }
                            const imgUrl = URL.createObjectURL(blob);
                            a.href = imgUrl;
                            a.download = fileName; 
                            a.click();
                            URL.revokeObjectURL(imgUrl);
                            resolve({ success: true });
                        }, "image/jpeg", 0.95); // 设置 JPG 质量为 0.95
                    }
                };

                img.onerror = () => {
                    console.error(`图片加载失败：${fileName}`);
                    URL.revokeObjectURL(url);
                    resolve({ success: false });
                };

                img.src = url;
            });
        } else if (format === "pdf") {
            return new Promise((resolve) => {
                const img = new Image();
                img.onload = async () => {
                    const canvas = document.createElement("canvas");
                    const pixelWidth = Math.round(width * DPI);
                    const pixelHeight = Math.round(height * DPI);
                    canvas.width = pixelWidth;
                    canvas.height = pixelHeight;
                    const ctx = canvas.getContext("2d");
                    ctx.drawImage(img, 0, 0, pixelWidth, pixelHeight);

                    const pdf = new window.jspdf.jsPDF({
                        unit: "pt",
                        format: [width * 72, height * 72],
                        orientation: width > height ? "landscape" : "portrait",
                    });

                    const imgData = canvas.toDataURL('image/jpeg', 1.0);
                    pdf.addImage(imgData, 'JPEG', 0, 0, width * 72, height * 72);
                    pdf.save(fileName); 
                    resolve({ success: true });
                };

                img.onerror = () => {
                    console.error(`图片加载失败：${fileName}`);
                    URL.revokeObjectURL(url);
                    resolve({ success: false });
                };

                img.src = url;
            });
        } else {
            a.click();
            URL.revokeObjectURL(url);
            return { success: true };
        }
    } catch (error) {
        console.error(`导出 ${format} 过程中发生错误：`, error);
        return { success: false };
    }
}



// 外部定义一个更新宽度和高度的函数
function updateDimensions(newWidth, newHeight) {
    exportFile_Width = newWidth;
    exportFile_Height = newHeight;
}




// 物种堆叠图
setupExportWithPlot(
    containerId = "species_stack_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "species_stack_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "species_stack_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "species_stack_exportWidth",               // 图像宽度输入框 ID
        heightId: "species_stack_exportHeight",             // 图像高度输入框 ID
        buttonId: "species_stack_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => species_stack_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawTaxaBarPlot,         // 绘图函数
    updateDimensions,                       // 传入更新宽度和高度的回调函数
    DPI = 220                               // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// // 弦图
// setupExportWithPlot(
//     containerId = "chord_diagram_control_export",  // 包含导出控件的容器 ID
//     ids = {
//         fileNameId: "chord_diagram_exportName",             // 文件名输入框 ID
//         fileTypeContainerId: "chord_diagram_exportName_checkbox_fileType",  // 文件格式复选框容器 ID
//         widthId: "chord_diagram_exportName_exportWidth",               // 图像宽度输入框 ID
//         heightId: "chord_diagram_exportName_exportHeight",             // 图像高度输入框 ID
//         buttonId: "chord_diagram_exportName_exportFile_button",        // 导出按钮 ID
//     },
//     getSvgData = () => chord_diagram_exportName_svg,   // 获取 SVG 数据的回调函数
//     plotFunction = drawChordDiagramPlot,    // 绘图函数
//     updateDimensions,                       // 传入更新宽度和高度的回调函数
//     DPI = 220                               // DPI，默认为 300，这里设置为 220
// );
// ------------------------------------------------------------------------------------------------

// Venn 图
setupExportWithPlot(
    containerId = "venn_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "venn_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "venn_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "venn_exportWidth",               // 图像宽度输入框 ID
        heightId: "venn_exportHeight",             // 图像高度输入框 ID
        buttonId: "venn_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => venn_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawVennPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// Upset 图
setupExportWithPlot(
    containerId = "upset_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "upset_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "upset_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "upset_exportWidth",               // 图像宽度输入框 ID
        heightId: "upset_exportHeight",             // 图像高度输入框 ID
        buttonId: "upset_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => upset_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawUpsetPlot,   // 绘图函数
    updateDimensions,               // 传入更新宽度和高度的回调函数
    DPI = 220                       // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// 箱线图
setupExportWithPlot(
    containerId = "boxplot_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "boxplot_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "boxplot_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "boxplot_exportWidth",               // 图像宽度输入框 ID
        heightId: "boxplot_exportHeight",             // 图像高度输入框 ID
        buttonId: "boxplot_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => boxplot_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawBoxplotPlot,   // 绘图函数
    updateDimensions,               // 传入更新宽度和高度的回调函数
    DPI = 220                       // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// PCA 图
setupExportWithPlot(
    containerId = "pca_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "pca_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "pca_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "pca_exportWidth",               // 图像宽度输入框 ID
        heightId: "pca_exportHeight",             // 图像高度输入框 ID
        buttonId: "pca_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => pca_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawPcaPlot,   // 绘图函数
    updateDimensions,             // 传入更新宽度和高度的回调函数
    DPI = 220                     // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// PCoA 图
setupExportWithPlot(
    containerId = "pcoa_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "pcoa_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "pcoa_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "pcoa_exportWidth",               // 图像宽度输入框 ID
        heightId: "pcoa_exportHeight",             // 图像高度输入框 ID
        buttonId: "pcoa_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => pcoa_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawPcoaPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// NMDS 图
setupExportWithPlot(
    containerId = "nmds_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "nmds_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "nmds_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "nmds_exportWidth",               // 图像宽度输入框 ID
        heightId: "nmds_exportHeight",             // 图像高度输入框 ID
        buttonId: "nmds_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => nmds_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawNmdsPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// RDA 图
setupExportWithPlot(
    containerId = "rda_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "rda_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "rda_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "rda_exportWidth",               // 图像宽度输入框 ID
        heightId: "rda_exportHeight",             // 图像高度输入框 ID
        buttonId: "rda_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => rda_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawRdaPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// CCA 图
setupExportWithPlot(
    containerId = "cca_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "cca_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "cca_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "cca_exportWidth",               // 图像宽度输入框 ID
        heightId: "cca_exportHeight",             // 图像高度输入框 ID
        buttonId: "cca_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => cca_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawCcaPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------

// 热图
setupExportWithPlot(
    containerId = "heatmap_control_export",  // 包含导出控件的容器 ID
    ids = {
        fileNameId: "heatmap_exportName",             // 文件名输入框 ID
        fileTypeContainerId: "heatmap_checkbox_fileType",  // 文件格式复选框容器 ID
        widthId: "heatmap_exportWidth",               // 图像宽度输入框 ID
        heightId: "heatmap_exportHeight",             // 图像高度输入框 ID
        buttonId: "heatmap_exportFile_button",        // 导出按钮 ID
    },
    getSvgData = () => heatmap_svg,   // 获取 SVG 数据的回调函数
    plotFunction = drawHeatmapPlot,   // 绘图函数
    updateDimensions,              // 传入更新宽度和高度的回调函数
    DPI = 220                      // DPI，默认为 300，这里设置为 220
);
// ------------------------------------------------------------------------------------------------