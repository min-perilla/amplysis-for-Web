// 点击后可以复制到粘贴板
document.querySelectorAll(".group1Auto, .group2Auto").forEach(element => {
    element.addEventListener("click", function () {
        const content = this.textContent.trim(); // 获取 p 元素的内容

        if (content) {
            // 复制到粘贴板
            navigator.clipboard.writeText(content).then(() => {
                showToast("已复制到粘贴板", "success", "bottom-right"); // 仅提示成功
            }).catch(err => {
                console.error("复制失败：", err); // 仅记录失败日志
            });
        }
    });
});

// 封装为复用的函数
function updateGroupValues(selectId1, selectId2 = null, pId1, pId2 = null) {
    // 获取分组1的选择值
    const group1Value = document.getElementById(selectId1).value;
    let group2Value = null;
    if (selectId2) {
        group2Value = document.getElementById(selectId2).value;
    }

    // 获取 sharedMetadataData 的列名
    const columnNames = Object.keys(sharedMetadataData[0] || {});
    // console.log("列名：", columnNames);

    // 定义更新 p 标签内容的函数
    function updatePContent(groupValue, columnNames, pId) {
        if (columnNames.includes(groupValue)) {
            const columnValues = sharedMetadataData.map(row => row[groupValue]);
            const uniqueValues = [...new Set(columnValues)]; // 去重


            // console.log(`已识别到列 "${groupValue}" 的值：`, uniqueValues);

            // 更新 p 标签内容
            document.getElementById(pId).textContent = uniqueValues.join(', ');
        } else {

            // console.log(`列 "${groupValue}" 不存在`);


            document.getElementById(pId).textContent = "无";
        }
    }

    // 更新分组1的内容
    updatePContent(group1Value, columnNames, pId1);

    // 如果 selectId2 和 pId2 不为 null，更新分组2的内容
    if (selectId2 && pId2) {
        updatePContent(group2Value, columnNames, pId2);
    }
}



// 添加事件监听，调用函数以实现实时更新
// ---------------------------------------------------------------------------------------
// 物种堆叠图
document.getElementById("species_stack_groupInformation1").addEventListener("change", () => {
    updateGroupValues("species_stack_groupInformation1", "species_stack_groupInformation2", "species_stack_group1Auto", "species_stack_group2Auto");
});

// // 弦图
// document.getElementById("chord_diagram_groupInformation2").addEventListener("change", () => {
//     updateGroupValues("chord_diagram_groupInformation1", null, "chord_diagram_group1Auto", null);
// });
// ---------------------------------------------------------------------------------------


// Upset 图
document.getElementById("upset_groupInformation1").addEventListener("change", () => {
    updateGroupValues("upset_groupInformation1", null, "upset_group1Auto", null);
});

// 盒线图
document.getElementById("boxplot_groupInformation1").addEventListener("change", () => {
    updateGroupValues("boxplot_groupInformation1", null, "boxplot_group1Auto", null);
});


// PCA 图
document.getElementById("pca_groupInformation1").addEventListener("change", () => {
    updateGroupValues("pca_groupInformation1", null, "pca_group1Auto", null);
});


// PCoA 图
document.getElementById("pcoa_groupInformation1").addEventListener("change", () => {
    updateGroupValues("pcoa_groupInformation1", null, "pcoa_group1Auto", null);
});


// NMDS 图
document.getElementById("nmds_groupInformation1").addEventListener("change", () => {
    updateGroupValues("nmds_groupInformation1", null, "nmds_group1Auto", null);
});


// RDA 图
document.getElementById("rda_groupInformation1").addEventListener("change", () => {
    updateGroupValues("rda_groupInformation1", null, "rda_group1Auto", null);
});

// 热图
document.getElementById("heatmap_groupInformation1").addEventListener("change", () => {
    updateGroupValues("heatmap_groupInformation1", null, "heatmap_group1Auto", null);
});






// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------
// 监听文件上传事件
document.getElementById("FileInput_metadata").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = function () {

            // ---------------------------------------------------------------------------------------
            // 文件读取完成后执行一次 updateGroupValues
            // 物种堆叠图
            updateGroupValues("species_stack_groupInformation1", "species_stack_groupInformation2", "species_stack_group1Auto", "species_stack_group2Auto");
            
            // // 弦图
            // updateGroupValues("chord_diagram_groupInformation1", null, "chord_diagram_group1Auto", null);

            //集合图
            updateGroupValues("upset_groupInformation1", null, "upset_group1Auto", null);
            
            //集合图
            updateGroupValues("boxplot_groupInformation1", null, "boxplot_group1Auto", null);

            //PCA
            updateGroupValues("pca_groupInformation1", null, "pca_group1Auto", null);

            //PCoA
            updateGroupValues("pcoa_groupInformation1", null, "pcoa_group1Auto", null);

            //NMDS
            updateGroupValues("nmds_groupInformation1", null, "nmds_group1Auto", null);

            //RDA
            updateGroupValues("rda_groupInformation1", null, "rda_group1Auto", null);

            //热图
            updateGroupValues("heatmap_groupInformation1", null, "heatmap_group1Auto", null);

            // ---------------------------------------------------------------------------------------
        };
        reader.readAsText(file);
    }
});
