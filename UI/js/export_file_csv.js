// 将数据导出为 CSV 文件的函数
function exportToCSV(data, filename) {
    try {
        // 如果没有传递文件名，使用默认文件名
        if (!filename) {
            filename = "default.csv";
        }

        // 构建 CSV 内容
        const headers = Object.keys(data[0]).join(","); // 获取表头
        const rows = data.map(row => Object.values(row).join(",")); // 获取每行数据
        const csvContent = [headers, ...rows].join("\n"); // 合并表头和数据行

        // 创建 Blob 对象
        const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });

        // 创建下载链接
        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", filename);
        link.style.visibility = "hidden";

        // 将链接添加到文档并触发点击
        document.body.appendChild(link);
        link.click();

        // 清理 URL 和 DOM
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        // 提示导出成功
        showToast("导出文件成功！", "success");
    } catch (error) {
        // 提示导出失败
        showToast("导出文件失败！", "error");
    }
}

// 给按钮绑定点击事件
// “数据预处理”页面
// “OTU数据抽平”
document.getElementById("preprocessing_rarefy_exportName_otu_button").addEventListener("click", () => {
    // 获取输入框的文件名
    const filename = document.getElementById("preprocessing_rarefy_exportName_otu").value.trim() || "otu_rarefy.csv";
    // 调用导出函数，指定数据和文件名
    exportToCSV(sharedFeatureData, filename);
});

// “Tax 表分列”
document.getElementById("preprocessing_separate_exportName_tax_button").addEventListener("click", () => {
    // 获取输入框的文件名
    const filename = document.getElementById("preprocessing_separate_exportName_tax").value.trim() || "tax_separated.csv";
    // 调用导出函数，指定数据和文件名
    exportToCSV(sharedTaxonomyData, filename);
});

// “Tax 表去前缀”
document.getElementById("preprocessing_prefix_exportName_tax_button").addEventListener("click", () => {
    // 获取输入框的文件名
    const filename = document.getElementById("preprocessing_prefix_exportName_tax").value.trim() || "tax_trimmed.csv";
    // 调用导出函数，指定数据和文件名
    exportToCSV(sharedTaxonomyData, filename);
});

// “Tax 表信息修复”
document.getElementById("preprocessing_repair_exportName_tax_button").addEventListener("click", () => {
    // 获取输入框的文件名
    const filename = document.getElementById("preprocessing_repair_exportName_tax").value.trim() || "tax_repaired.csv";
    // 调用导出函数，指定数据和文件名
    exportToCSV(sharedTaxonomyData, filename);
});

// ---------------------------------------------------------------------------
// 导出多个文件
function exportMultipleCSVs(dataArray, inputElementId, defaultFilename, suffixes = []) {
    try {
        // 获取输入框中的文件名
        const inputElement = document.getElementById(inputElementId);
        if (!inputElement) {
            console.log("找不到输入框元素:", inputElementId);
            showToast("找不到输入框！", "error");
            return;
        }

        let baseFilename = inputElement.value.trim(); // 获取输入框中的文件名，并去除空格

        // 如果文件名为空，则使用默认文件名
        if (!baseFilename) {
            baseFilename = defaultFilename;
        }

        // 依次导出数据
        dataArray.forEach((data, index) => {
            if (data && data.length > 0) {
                // 确定文件后缀
                const suffix = suffixes[index] || ""; // 默认没有后缀
                const filename = `${baseFilename}${suffix}.csv`;

                // 调试：检查生成的文件名
                console.log("导出文件名：", filename);

                // 直接传递 filename 给 exportToCSV
                exportToCSV(data, filename);
            } else {
                showToast(`数据 ${index + 1} 为空，未导出文件！`, "warning");
            }
        });

    } catch (error) {
        console.error("导出文件时发生错误:", error);
        showToast("导出文件时发生错误！", "error");
    }
}

// 绑定点击事件：点击按钮导出多个文件
document.addEventListener("DOMContentLoaded", function() {
    document.getElementById("cooccurrence_exportFile_button").addEventListener("click", () => {
        // 获取输入框的文件名
        const filename = document.getElementById("cooccurrence_network_exportName").value.trim() || "network";

        // 调用导出函数，指定数据、输入框 ID、默认文件名和后缀数组
        exportMultipleCSVs(
            [
                cooccurrence_network_file_edge,  // 边数据
                cooccurrence_network_file_node,  // 节点数据
                // 如果有其他数据，可以继续添加
            ],
            "cooccurrence_network_exportName",    // 文件名输入框 ID
            filename,                            // 使用输入框的文件名前缀
            ["_edge", "_node"]                    // 对应的文件后缀
        );
    });
});
