// 重置文件

/**
 * 处理重置按钮点击的函数
 * @param {Array<string>} otu_table_container_ids - OTU 表格容器的 ID 数组
 * @param {Array<string>} tax_table_container_ids - tax 表格容器的 ID 数组
 * @param {Array<string>} rep_table_container_ids - rep 表格容器的 ID 数组
 */
function reset_otu_button_click(otu_table_container_ids, tax_table_container_ids, rep_table_container_ids) {
    try {
        // 检测 OTU 备份数据
        if (!preprocessing_rarefy_is_otu_backup) {
            showToast("没有可用的数据进行重置！", "error");
            return;
        }

        // 恢复 OTU 数据
        generateOrUpdateTable(sharedFeatureData_backup, otu_table_container_ids);
        sharedFeatureData = JSON.parse(JSON.stringify(sharedFeatureData_backup)); // 深拷贝，防止影响备份数据
        preprocessing_rarefy_is_otu_backup = false;

        let message = "OTU 表重置成功！";

        // 恢复 Tax 数据
        if (preprocessing_rarefy_is_tax_backup) {
            generateOrUpdateTable(sharedTaxonomyData_backup, tax_table_container_ids);
            sharedTaxonomyData = JSON.parse(JSON.stringify(sharedTaxonomyData_backup));
            preprocessing_rarefy_is_tax_backup = false;
            message = "OTU、tax 表重置成功！";
        }

        // **修改这里，避免清空 `sharedRepSeqsData_backup`**
        if (preprocessing_rarefy_is_rep_backup) {
            generateOrUpdateTable(sharedRepSeqsData_backup, rep_table_container_ids);
            sharedRepSeqsData = JSON.parse(JSON.stringify(sharedRepSeqsData_backup)); // 深拷贝，保留备份数据
            preprocessing_rarefy_is_rep_backup = false;
            message = "OTU、tax、rep 表重置成功！";
        }

        showToast(message, "success");

    } catch (error) {
        console.error("重置表时发生错误:", error);
        showToast("重置过程中发生错误，请重试！", "error");
    }
}


// OTU数据抽平
// 重置按钮的点击事件绑定
document.getElementById("preprocessing_rarefy_resetting_otu_button").addEventListener("click", function () {
    reset_otu_button_click(
        ["feature_table_container", "feature_table_container_preprocessing"],

        ["taxonomy_table_container", "taxonomy_table_container_preprocessing"],

        ["rep_seqs_container"]
    );
});






// ----------------------------------------------------------------------------------------------------------
// tax 表：数据分列、去前缀、修复

/**
 * 处理重置按钮点击的函数
 * @param {Array<string>} table_container_ids - 表格容器的 ID 数组
 * @param {Object} backupStatus - 包含备份标志的对象
 * @param {string} key - 要检查的标志属性名
 */
function reset_tax_button_click(table_container_ids, backupStatus, key) {
    try {
        // 检测备份数据是否存在
        if (backupStatus[key] === false) {
            showToast("没有可用的数据进行重置！", "error");
            return;
        }

        // 更新表格
        generateOrUpdateTable(sharedTaxonomyData_backup, table_container_ids);


        // 更新所有的“分类等级”选择框
        // 获取列名
        const taxonomyLevels = Object.keys(sharedTaxonomyData_backup[0]).slice(1);
        populateTaxonomySelectors(taxonomyLevels, "select_tax_class");  // 更新选择框


        // 更新主数据，恢复数据
        sharedTaxonomyData = sharedTaxonomyData_backup; // 直接更新全局变量

        // 重置备份数据
        sharedTaxonomyData_backup = null; // 直接更新全局变量

        // 重置所有标志
        for (const flag in backupStatus) {
            if (backupStatus.hasOwnProperty(flag)) {
                backupStatus[flag] = false;
            }
        }

        // 显示成功提示
        showToast("tax 表重置成功！", "success");
    } catch (error) {
        // 捕获异常并提示错误信息
        console.error("重置表时发生错误:", error);
        showToast("重置过程中发生错误，请重试！", "error");
    }
}

// “数据预处理”界面
// Tax表分列
// 重置按钮的点击事件绑定
document.getElementById("preprocessing_separate_resetting_tax_button").addEventListener("click", function () {
    reset_tax_button_click(
        ["taxonomy_table_container", "taxonomy_table_container_preprocessing"],
        taxBackupStatus,
        "separate"
    );
});

// Tax表去前缀
// 重置按钮的点击事件绑定
document.getElementById("preprocessing_prefix_resetting_tax_button").addEventListener("click", function () {
    reset_tax_button_click(
        ["taxonomy_table_container", "taxonomy_table_container_preprocessing"],
        taxBackupStatus,
        "trimPrefix"
    );
});

// Tax表修复
// 重置按钮的点击事件绑定
document.getElementById("preprocessing_repair_resetting_tax_button").addEventListener("click", function () {
    reset_tax_button_click(
        ["taxonomy_table_container", "taxonomy_table_container_preprocessing"],
        taxBackupStatus,
        "namesRepair"
    );
});


