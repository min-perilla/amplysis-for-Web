// 从样本元数据获取分组信息，分配到各视图的“选择分组”选择框中
function populateSelectWithGroups(groups, group1Class, group2Class) {
    const group1Selects = document.querySelectorAll(`.${group1Class}`);
    const group2Selects = document.querySelectorAll(`.${group2Class}`);

    // 清空所有选择框的现有选项
    [...group1Selects, ...group2Selects].forEach(select => {
        select.innerHTML = ''; // 清空选项
    });

    // 先给所有 group2Class 的选择框添加“无”选项
    group2Selects.forEach(select => {
        const noneOption = document.createElement('option');
        noneOption.value = '无';
        noneOption.textContent = '无';
        select.appendChild(noneOption); // 将“无”选项添加到选择框中
        select.selectedIndex = 0; // 默认选择“无”
    });

    // 遍历分组信息，将每个分组添加为下拉菜单的一个选项
    [...group1Selects, ...group2Selects].forEach(select => {
        groups.forEach(group => {
            const option = document.createElement('option');
            option.value = group;
            option.textContent = group;
            select.appendChild(option);
        });
    });
}



// 设置分组1和分组2的互斥效果
function setupMutualExclusionById(group1Id, group2Id) {
    const group1Select = document.getElementById(group1Id);
    const group2Select = document.getElementById(group2Id);

    // 当分组1的选择发生改变时，更新分组2的选项
    group1Select.addEventListener('change', () => {
        updateGroup2Options(group1Select, group2Select);
    });

    // 初次加载时调用该函数，以便根据默认选择过滤分组2
    updateGroup2Options(group1Select, group2Select);
}


// 更新分组2的选项，根据分组1的选择移除对应的选项
function updateGroup2Options(group1Select, group2Select) {
    const selectedGroup1Value = group1Select.value; // 获取分组1当前选择的值

    // 清空分组2的现有选项，保留“无”选项
    const noneOption = Array.from(group2Select.options).find(option => option.value === '无');
    group2Select.innerHTML = ''; // 清空所有选项
    if (noneOption) {
        group2Select.appendChild(noneOption); // 添加“无”选项
    }

    // 遍历分组1的选项，将所有选项（除分组1选择的值）添加到分组2
    Array.from(group1Select.options).forEach(option => {
        // 不添加分组1选择的值和“无”选项
        if (option.value !== selectedGroup1Value && option.value !== '无') {
            const newOption = document.createElement('option'); // 为分组2创建新选项
            newOption.value = option.value; // 设置新选项的值
            newOption.textContent = option.textContent; // 设置新选项的文本内容
            group2Select.appendChild(newOption); // 将新选项添加到分组2
        }
    });

    // 默认设置分组2选择“无”
    group2Select.value = '无'; // 重新选择“无”
}



// -------------------------------------------------------------------
// 平行样
// 将平行样信息填充到具有指定类名的选择框
function populateSelectWithParallel(className, parallels) {
    const selects = document.querySelectorAll(`.${className}`);

    selects.forEach(select => {
        select.innerHTML = '';  // 清空当前 <select> 元素的所有现有选项

        parallels.forEach(parallel => { // 遍历传入的平行样选项数组
            const option = document.createElement('option'); // 为每个平行样选项创建一个新的 <option> 元素
            option.value = parallel; // 设置平行样的值
            option.textContent = parallel; // 设置平行样的显示文本
            select.appendChild(option); // 将 <option> 元素添加到当前 <select> 元素中
        });

        // 添加“无”选项
        // const noneOption = document.createElement('option');
        // noneOption.value = '无';
        // noneOption.textContent = '无';
        // select.appendChild(noneOption);
    });
}


// 平行样处理方法
// 为所有具有 class="parallelMethods" 的 <select> 元素添加选项
function populateParallelMethodsSelect() {
    // 获取所有具有指定类名的选择框
    const selects = document.querySelectorAll('.parallelMethods');

    // 遍历每个选择框
    selects.forEach(select => {
        // 清空当前选择框的所有选项
        select.innerHTML = '';

        // 创建并添加选项
        const options = [
            { value: 'mean', text: '平均' },
            { value: 'sum', text: '求和' },
            { value: 'median', text: '中位数' },
            { value: 'none', text: '不处理' }
        ];

        options.forEach(optionData => {
            const option = document.createElement('option'); // 创建新的选项
            option.value = optionData.value; // 设置选项值
            option.textContent = optionData.text; // 设置选项文本
            select.appendChild(option); // 将选项添加到选择框中
        });


        // 设置默认选项为“平均”，如果不是特定 ID 则为“平均”，
        // 否则设置为“没有处理”
        if (['boxplot_parallelMethods',
            'pca_parallelMethods', 'pcoa_parallelMethods',
            'nmds_parallelMethods', 'rda_parallelMethods', 'cca_parallelMethods', 
            'cooccurrence_network_parallelMethods'
        ].includes(select.id)) {
            select.value = 'none'; // 默认选择“不处理”
        } else {
            select.value = 'mean'; // 默认选择“平均”
        }


    });
}



// -------------------------------------------------------------------
// 样本元数据文件上传事件监听器
document.getElementById("FileInput_metadata").addEventListener("change", function (event) {
    const file = event.target.files[0]; // 获取上传的文件
    if (file) {
        parseCSVFile(file, function (data) {
            generateOrUpdateTable(data, ["metadata_container"]); // 生成样本元数据表格

            const headers = Object.keys(data[0]); // 获取数据的表头
            const groups = new Set(); // 使用 Set 存储唯一的分组名称
            const parallels = new Set(); // 使用 Set 存储唯一的平行样名称

            // 遍历列名，筛选出分组和平行样列
            headers.forEach(header => {
                const lowerHeader = header.trim().toLowerCase();
                if (lowerHeader.startsWith('group')) {
                    groups.add(header.trim()); // 识别以"group"开头的列作为分组信息
                }
                if (lowerHeader.includes('parallel')) {
                    parallels.add(header.trim()); // 识别包含"parallel"的列作为平行样信息
                }
            });

            // 分组
            // 将分组信息填充到选择框，通过类名识别分组 1 和分组 2
            populateSelectWithGroups(
                Array.from(groups),  // 将 Set 转换为数组
                'groups_select',     // 分组 1 的类名
                'groups_select2'     // 分组 2 的类名
            );

            // 平行样
            // 将平行样信息填充到具有 class="parallel_select" 的选择框
            populateSelectWithParallel('parallel_select', Array.from(parallels));

            // 分组1和分组2互斥效果
            setupMutualExclusionById('species_stack_groupInformation1', 'species_stack_groupInformation2');
            // setupMutualExclusionById('chord_diagram_groupInformation1', 'chord_diagram_groupInformation2');

            // 为所有具有 class="parallelMethods" 的 <select> 元素添加选项
            populateParallelMethodsSelect();
        });
    }
});




