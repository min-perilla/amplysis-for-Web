// tax 表去前缀
// 为 id 为 "plot_button_preprocessing_prefix" 的按钮添加点击事件监听器
document.getElementById("plot_button_preprocessing_prefix").addEventListener("click", async () => {
    try {

        console.log("已提交信息：执行tax表去前缀");


        // 获取 Tax 信息
        const taxonomyData = sharedTaxonomyData;  // Tax


        // 获取其他参数
        const prefix_index = document.getElementById("preprocessing_prefix_index_textarea").value.trim();  // 修剪位置
        const prefix_length = document.getElementById("preprocessing_prefix_length").value;  // 修剪长度


        // 构造请求体
        const requestBody = {
            taxonomyData,
            prefix_index,
            prefix_length
        };


        // 构造 POST 请求
        const response = await fetch(`${apiBaseURL}/tax_trim_prefix`, { // 使用 apiBaseURL 构建完整的 API URL
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


        // 更新 sharedTaxonomyData 并更新表格
        if (Array.isArray(result.tax_trimmed) && result.tax_trimmed.length === 1 && result.tax_trimmed[0] === -1) {
            console.warn("输入的 Tax 表为空");
            showToast("Tax 表为空！", "error", "bottom-right");

        } else if (result.tax_trimmed) {

            // 更新表格
            generateOrUpdateTable(result.tax_trimmed, ["taxonomy_table_container", "taxonomy_table_container_preprocessing"]);  // 更新 tax 表格


            // 更新所有的“分类等级”选择框
            // 获取列名
            const taxonomyLevels = Object.keys(result.tax_trimmed[0]).slice(1);
            populateTaxonomySelectors(taxonomyLevels, "select_tax_class");  // 更新选择框

            // 保存一个副本,方便重置
            sharedTaxonomyData_backup = sharedTaxonomyData;



            // 更新 tax 表其他备份标志：设置当前标志为 true，其余标志为 false
            for (const key in taxBackupStatus) {
                taxBackupStatus[key] = key === "trimPrefix";
            }

            // 更新数据分列的备份标志，防止冲突
            preprocessing_rarefy_is_otu_backup = false;



            // 更新变量：将后端返回的 tax 表数据赋值给全局变量
            sharedTaxonomyData = result.tax_trimmed;

            showToast("Tax 表更新成功！", "success", "bottom-right");

        } else {
            console.warn("后端未返回有效的 tax 表数据");

            showToast("后端未返回有效数据", "error", "bottom-right");
        }
    } catch (error) {
        console.error("调用 /tax_separate 接口失败：", error);

        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
});

