// 为 id 为 "plot_button_preprocessing_rarefy" 的按钮添加点击事件监听器
// 调用数据抽平函数：data_rarefy
document.getElementById("plot_button_preprocessing_rarefy").addEventListener("click", async () => {
    try {

        console.log("已提交信息：执行数据抽平");


        // 获取 OTU 和 Tax 信息
        const featureData = sharedFeatureData;     // OTU
        const taxonomyData = sharedTaxonomyData;   // Tax
        const RepSeqsData = sharedRepSeqsData      // Rep


        // 获取其他参数
        const method = document.getElementById("preprocessing_rarefy_methods").value;         // 抽平方法
        const seed = document.getElementById("preprocessing_rarefy_seed").value;              // 随机种子值
        const replace = document.getElementById("preprocessing_rarefy_replace").value;        // 是否启用替代采样
        const trimOTUs = document.getElementById("preprocessing_rarefy_trimOTUs").value;      // 是否移除空行
        const alignTax = document.getElementById("preprocessing_rarefy_alignTax").value;      // 是否启用对齐 tax 表
        const alignRep = document.getElementById("preprocessing_rarefy_alignRep").value;      // 是否启用对齐 rep 表


        // 构造请求体
        const requestBody = {
            featureData,
            taxonomyData,
            RepSeqsData,

            method,
            seed,
            replace,
            trimOTUs,
            alignTax,
            alignRep
        };


        // 构造 POST 请求
        const response = await fetch(`${apiBaseURL}/data_rarefy`, { // 使用 apiBaseURL 构建完整的 API URL
            method: "POST",
            headers: {
                "Content-Type": "application/json", // 告知服务器传递 JSON 数据
            },
            body: JSON.stringify(requestBody)  // 发送请求体
        });


        // 检查响应是否成功
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }


        // 解析后端返回的数据
        const result = await response.json();
        console.log("后端返回结果：", result);


        // 更新 sharedFeatureData 并更新表格
        if (Array.isArray(result.otu_rarefy) && result.otu_rarefy.length === 1 && result.otu_rarefy[0] === -1) {
            console.warn("输入的 OTU 表为空");
            showToast("OTU 表为空！", "error", "bottom-right");

        } else if (result.otu_rarefy) {

            let updatedTables = ["OTU"]; // 记录更新的表格

            // 保存 OTU 备份，方便重置
            sharedFeatureData_backup = sharedFeatureData;
            preprocessing_rarefy_is_otu_backup = true;

            // 更新 OTU 数据
            sharedFeatureData = result.otu_rarefy;
            generateOrUpdateTable(sharedFeatureData, ["feature_table_container", "feature_table_container_preprocessing"]);

            // 处理 tax 表更新
            if (Object.keys(result.tax_align).length > 0 && trimOTUs === "TRUE" && alignTax === "TRUE") {
                // 保存 tax 备份，方便重置
                sharedTaxonomyData_backup = sharedTaxonomyData;
                preprocessing_rarefy_is_tax_backup = true;

                // 重置 tax 备份标志，防止冲突
                for (const flag in taxBackupStatus) {
                    if (taxBackupStatus.hasOwnProperty(flag)) {
                        taxBackupStatus[flag] = false;
                    }
                }

                // 更新 tax 数据
                sharedTaxonomyData = result.tax_align;
                generateOrUpdateTable(result.tax_align, ["taxonomy_table_container", "taxonomy_table_container_preprocessing"]);

                // 更新分类等级选择框
                const taxonomyLevels = Object.keys(result.tax_align[0]).slice(1);
                populateTaxonomySelectors(taxonomyLevels, "select_tax_class");

                updatedTables.push("Tax"); // 记录 Tax 表已更新
            }

            // 处理 Rep（代表性序列）更新
            if (Object.keys(result.rep).length > 0 && trimOTUs === "TRUE" && alignRep === "TRUE") {
                // 备份 Rep 数据，方便重置
                sharedRepSeqsData_backup = sharedRepSeqsData;
                preprocessing_rarefy_is_rep_backup = true;

                // 更新 Rep 数据
                sharedRepSeqsData = result.rep;
                generateOrUpdateTable(sharedRepSeqsData, ["rep_seqs_container"]);

                updatedTables.push("Rep"); // 记录 Rep 表已更新
            }

            // 生成最终的提示信息
            showToast(`${updatedTables.join("、")} 表同步更新成功！`, "success", "bottom-right");

        } else {
            console.warn("后端未返回有效的 OTU 数据");
            showToast("后端未返回有效数据", "error", "bottom-right");
        }


    } catch (error) {
        console.error("调用 /data_rarefy 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
});

