// 创建表格

// 解析 CSV 文件的通用函数
function parseCSVFile(file, callback) {
    // 使用 Papa Parse 解析 CSV 文件
    Papa.parse(file, {
        header: true,            // 将首行作为表头
        skipEmptyLines: true,     // 跳过空行
        complete: function (results) {
            callback(results.data); // 解析完成后，调用回调函数并传递解析后的数据
        }
    });
}


// 生成或更新表格的函数
function generateOrUpdateTable(data, tableContainerIds) {
    // 遍历给定的容器ID数组，在每个容器中生成或更新表格
    tableContainerIds.forEach(id => {
        populateTable(id, data);
    });
}


// 填充表格的函数
function populateTable(tableContainerId, data) {
    // 获取指定的表格容器元素
    const tableContainer = document.getElementById(tableContainerId);
    if (!tableContainer) return; // 如果容器不存在，则退出

    // 清空容器内容，准备生成新的表格
    tableContainer.innerHTML = "";

    // 创建表格元素
    const table = document.createElement("table");
    table.className = "table table-striped table-bordered display"; // 设置表格的 CSS 类样式
    table.id = tableContainerId + "_table"; // 给表格设置一个唯一 ID

    // 创建表头部分
    const thead = document.createElement("thead");
    const headerRow = document.createElement("tr"); // 创建表头行
    Object.keys(data[0]).forEach((key) => {
        const th = document.createElement("th");
        th.textContent = key; // 设置表头单元格文本为字段名
        headerRow.appendChild(th); // 将表头单元格添加到表头行
    });
    thead.appendChild(headerRow); // 将表头行添加到表头
    table.appendChild(thead); // 将表头添加到表格

    // 创建表体部分
    const tbody = document.createElement("tbody");
    data.forEach((row) => {
        const tr = document.createElement("tr"); // 创建数据行
        Object.values(row).forEach((value) => {
            const td = document.createElement("td"); // 创建数据单元格
            td.textContent = value; // 设置单元格内容
            tr.appendChild(td); // 将单元格添加到数据行
        });
        tbody.appendChild(tr); // 将数据行添加到表体
    });
    table.appendChild(tbody); // 将表体添加到表格
    tableContainer.appendChild(table); // 将表格添加到容器

    initializeDataTable(table); // 调用函数初始化 DataTable 插件
}


// 初始化 DataTable 插件
function initializeDataTable(table) {
    // 获取当前窗口的高度（页面可视高度，受浏览器窗口大小影响）
    var windowHeight = $(window).height();

    // 获取当前页面的缩放比例（125%缩放时是1.25）
    var zoomFactor = window.devicePixelRatio;

    // 设定每行的高度（这个是你自己设的固定值，真实行高可根据DataTable样式微调）
    var rowHeight = 40;

    // 计算理论行数，基于窗口高度（和浏览器窗口高度相关，向下取整）
    var pageLength = Math.floor((windowHeight / rowHeight) / zoomFactor * 0.75);

    // // 日志输出详细信息，方便排查
    // console.log("【DataTable初始化日志】");
    // console.log("窗口高度($(window).height())：", windowHeight);
    // console.log("设备像素比(devicePixelRatio)：", zoomFactor);
    // console.log("每行高度(rowHeight)：", rowHeight);
    // console.log("实际使用的pageLength：", pageLength);

    // 初始化 DataTable 插件
    $(table).DataTable({
        scrollY: true,
        scrollX: true,
        autoWidth: true,
        paging: true,
        searching: true,
        ordering: true,
        order: [],
        pageLength: pageLength, // 使用动态计算的行数
        deferRender: true,
        lengthMenu: [[pageLength, 5, 10, 15, 20, 30, 50], [pageLength, 5, 10, 15, 20, 30, 50]],
        language: {
            search: "搜索：",
            lengthMenu: "展示 _MENU_ 条数据",
            info: "显示 _START_ 到 _END_ 条，共 _TOTAL_ 条",
            paginate: { first: "首页", last: "尾页", next: "下一页", previous: "上一页" },
            emptyTable: "没有数据",
            zeroRecords: "未找到符合条件的记录",
            loadingRecords: "正在加载中...",
            infoEmpty: "没有可用的记录",
            infoFiltered: "(从 _MAX_ 条记录中过滤)",
            processing: "处理中...",
            searchPlaceholder: "搜索...",
        }
    });
}



// function initializeDataTable(table) {
//     $(table).DataTable({
//         scrollY: true,
//         scrollX: true,
//         autoWidth: true,
//         paging: true,
//         searching: true,
//         ordering: true,
//         order: [],
//         pageLength: 15,
//         deferRender: true,
//         lengthMenu: [[5, 10, 15, 20, 50], [5, 10, 15, 20, 50]],
//         language: {
//             search: "搜索：",
//             lengthMenu: "展示 _MENU_ 条数据",
//             info: "显示 _START_ 到 _END_ 条，共 _TOTAL_ 条",
//             paginate: { first: "首页", last: "尾页", next: "下一页", previous: "上一页" },
//             emptyTable: "没有数据",
//             zeroRecords: "未找到符合条件的记录",
//             loadingRecords: "正在加载中...",
//             infoEmpty: "没有可用的记录",
//             infoFiltered: "(从 _MAX_ 条记录中过滤)",
//             processing: "处理中...",
//             searchPlaceholder: "搜索...",
//         }
//     });
// }


// 切换到相应的视图并激活按钮
function switchToView(targetId) {
    // 隐藏所有表格容器
    const containers = document.querySelectorAll('#preview_nav .table_page');
    containers.forEach(container => {
        container.style.display = 'none'; // 隐藏
    });

    // 显示目标容器
    const targetContainer = document.getElementById(targetId);
    if (targetContainer) {
        targetContainer.style.display = 'block'; // 显示目标容器
    }

    // 激活对应的按钮
    const previewNavButtons = document.querySelectorAll('#preview_nav .table_nav_list .button_nav');

    // 移除导航栏组中所有按钮的 'action' id
    previewNavButtons.forEach(btn => {
        btn.removeAttribute('id');
    });

    // 根据上传的文件，为相应按钮添加上 'action' id
    const activeButton = document.querySelector(`.button_a[data-target="${targetId}"] .button_nav`);
    if (activeButton) {
        activeButton.setAttribute('id', 'action'); // 为当前按钮添加 'action' ID
    }
}



// 事件监听器 - 读取特征表文件并共享
document.getElementById("FileInput_feature_table").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        parseCSVFile(file, function (data) {
            sharedFeatureData = data;

            switchToView("feature_table_container"); // 切换视图
            generateOrUpdateTable(sharedFeatureData, ["feature_table_container", "feature_table_container_preprocessing"]);


            isFeatureTableUploaded = true; // 更新上传状态
            console.log("特征表已上传");
        });
    }
});


// 事件监听器 - 读取分类表文件并共享
document.getElementById("FileInput_taxonomy_table").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        parseCSVFile(file, function (data) {
            sharedTaxonomyData = data;

            switchToView("taxonomy_table_container"); // 切换视图
            generateOrUpdateTable(sharedTaxonomyData, ["taxonomy_table_container", "taxonomy_table_container_preprocessing"]);

            isTaxonomyTableUploaded = true; // 更新上传状态
            console.log("分类表已上传");
        });
    }
});


// 代表性序列文件上传事件监听器
document.getElementById("FileInput_rep-seqs").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        parseCSVFile(file, function (data) {
            sharedRepSeqsData = data;

            switchToView("rep_seqs_container"); // 切换视图
            generateOrUpdateTable(sharedRepSeqsData, ["rep_seqs_container"]);


            isRepSeqsUploaded = true; // 更新上传状态
            console.log("代表性序列文件已上传");
        });
    }
});


// 样本元数据文件上传事件监听器
document.getElementById("FileInput_metadata").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        parseCSVFile(file, function (data) {
            sharedMetadataData = data;

            switchToView("metadata_container"); // 切换视图
            generateOrUpdateTable(sharedMetadataData, ["metadata_container"]);


            isMetadataUploaded = true; // 更新上传状态
            console.log("样本元数据文件已上传");
        });
    }
});


// 系统发育树文件上传事件监听器
document.getElementById("FileInput_tree").addEventListener("change", function (event) {
    const file = event.target.files[0]; // 获取上传的文件
    if (file) {
        const reader = new FileReader();
        reader.onload = function (e) {
            const newickData = e.target.result; // 读取文件内容（假设是 Newick 格式）
            sharedTreeData = newickData; // 将系统发育树数据存储到全局变量

            // 显示提示信息，添加动画类
            const successContainer = document.querySelector("#tree_container .tree_import_successful");
            successContainer.style.display = "flex"; // 设置为 flex 显示
            successContainer.classList.add("fade-in"); // 添加淡入动画类

            // console.log("系统发育树文件内容：", newickData);
        };

        // 以文本形式读取文件内容
        reader.readAsText(file);

        // 更新状态
        isTreeUploaded = true; // 标记为已上传

        switchToView("tree_container"); // 切换到树容器视图
        console.log("系统发育树文件已上传：", file.name);


    }
});


// 环境因子文件上传事件监听器
document.getElementById("FileInput_env").addEventListener("change", function (event) {
    const file = event.target.files[0];
    if (file) {
        parseCSVFile(file, function (data) {
            sharedEnvData = data;

            switchToView("env_container"); // 切换视图
            generateOrUpdateTable(sharedEnvData, ["env_container"]);


            isMetadataUploaded = true; // 更新上传状态
            console.log("环境因子文件已上传");
        });
    }
});




