// 监听 tax 表，解析所有的分类等级（列名），添加到各绘图参数的“分类等级”选择框上
// 从分类等级信息填充到选择框
function populateTaxonomySelectors(taxonomyLevels, selectClass) {
    // 获取所有class等于selectClass的选择框，比如 class="select_tax_class"
    const selectors = document.querySelectorAll(`.${selectClass}`);
    
    selectors.forEach((selector) => {
        // 清空当前选择框的所有选项，防止重复添加
        selector.innerHTML = "";

        // 创建一个DocumentFragment，用来批量添加选项（性能更好）
        const fragment = document.createDocumentFragment();

        // 遍历传入的分类等级数组，每个等级都创建一个<option>选项
        taxonomyLevels.forEach((level) => {
            const option = document.createElement("option");  // 创建<option>元素
            option.value = level;                             // 设置选项的值
            option.textContent = level;                       // 设置选项显示的文本
            fragment.appendChild(option);                     // 添加到fragment中
        });

        // 一次性把所有选项添加到选择框
        selector.appendChild(fragment);

        // 如果有分类等级数据，设置一个默认选中的分类等级
        if (taxonomyLevels.length > 0) {
            let priorityLevels;

            // 判断当前选择框的id，如果是特定的id就优先“genus”，否则走“phylum”
            const selectorId = selector.id;  // 获取当前选择框的id

            if (["heatmap_classification"].includes(selectorId)) {
                priorityLevels = ["genus", "genera", "g", "g_", "g__"];
            } else {
                priorityLevels = ["phylum", "phyla", "p", "p_", "p__"];
            }

            // 在分类等级数组里，找到第一个优先级匹配的分类等级
            let defaultIndex = taxonomyLevels.findIndex(level =>
                priorityLevels.includes(level.toLowerCase())
            );

            // 如果没有找到匹配的优先级，默认选第一个分类等级
            selector.selectedIndex = defaultIndex === -1 ? 0 : defaultIndex;
        }
    });
}





// 解析文件并更新分类等级的选择框
function handleFileUpload(file, selectClass) {
    const reader = new FileReader();
    reader.onload = function (e) {
        const text = e.target.result;
        const lines = text.split(/\r?\n/);

        // 确保文件有效
        if (lines.length === 0) {
            console.error("The uploaded file is empty.");
            return;
        }

        // 解析文件内容到临时变量（不修改 sharedTaxonomyData）
        const tempTaxonomyData = lines.map(line => line.split(",").map(cell => cell.trim()));

        // 检查数据格式
        if (tempTaxonomyData[0].length < 2) {
            console.error("Invalid file format: not enough columns.");
            return;
        }

        // 提取分类等级列，并去掉多余引号
        const taxonomyLevels = tempTaxonomyData[0].slice(1).map(level => level.replace(/^["']|["']$/g, ""));

        // 检查分类等级是否有效
        if (taxonomyLevels.length === 0) {
            console.error("No taxonomy levels found in the file.");
            return;
        }

        // 填充选择框
        populateTaxonomySelectors(taxonomyLevels, selectClass);
    };

    reader.onerror = function () {
        console.error("Error reading the file.");
    };

    reader.readAsText(file);
}

// 监听文件上传事件
document.getElementById("FileInput_taxonomy_table").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        handleFileUpload(file, "select_tax_class");
    }
});
