function collectFormValues(containerId) {
    // 创建一个对象来存储所有表单元素的值
    const formValues = {};

    // 获取指定容器内带有 class="plot_infomation" 的元素
    const container = document.getElementById(containerId);
    const inputs = container.querySelectorAll('.plot_infomation');

    // 遍历所有带有该 class 的输入元素
    inputs.forEach(input => {
        if (input.type === 'checkbox') {
            // 检查复选框是否被勾选
            if (input.checked) {
                formValues[input.name] = formValues[input.name] || [];
                formValues[input.name].push(input.value);
            }
        } else {
            // 处理其他类型的输入
            formValues[input.id] = input.value;
        }
    });

    return formValues; // 返回收集到的值
}



// 给绘图按钮添加监听事件
// 数据预处理(OTU数据抽平)
document.getElementById('plot_button_preprocessing_rarefy').addEventListener('click', () => {
    const values = collectFormValues('preprocessing_rarefy_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 数据预处理(tax表分列)
document.getElementById('plot_button_preprocessing_separate').addEventListener('click', () => {
    const values = collectFormValues('preprocessing_separate_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 数据预处理(tax表去前缀)
document.getElementById('plot_button_preprocessing_prefix').addEventListener('click', () => {
    const values = collectFormValues('preprocessing_prefix_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 数据预处理(tax表修复)
document.getElementById('plot_button_preprocessing_repair').addEventListener('click', () => {
    const values = collectFormValues('preprocessing_repair_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 物种堆叠图
document.getElementById('plot_button_species_stack').addEventListener('click', () => {
    const values = collectFormValues('species_stack_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// // -------------------------------------------------
// // 弦图
// document.getElementById('plot_button_chord_diagram').addEventListener('click', () => {
//     const values = collectFormValues('chord_diagram_control_items'); // 调用函数并传入容器 ID
//     console.log(values); // 输出到控制台以便调试
// });



// -------------------------------------------------
// 韦恩图
document.getElementById('plot_button_venn').addEventListener('click', () => {
    const values = collectFormValues('venn_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 集合图
document.getElementById('plot_button_upset').addEventListener('click', () => {
    const values = collectFormValues('upset_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 箱线图
document.getElementById('plot_button_boxplot').addEventListener('click', () => {
    const values = collectFormValues('boxplot_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// PCA
document.getElementById('plot_button_pca').addEventListener('click', () => {
    const values = collectFormValues('pca_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// PCoA
document.getElementById('plot_button_pcoa').addEventListener('click', () => {
    const values = collectFormValues('pcoa_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// NMDS
document.getElementById('plot_button_nmds').addEventListener('click', () => {
    const values = collectFormValues('nmds_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// RDA
document.getElementById('plot_button_rda').addEventListener('click', () => {
    const values = collectFormValues('rda_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// CCA
document.getElementById('plot_button_cca').addEventListener('click', () => {
    const values = collectFormValues('cca_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 热图
document.getElementById('plot_button_heatmap').addEventListener('click', () => {
    const values = collectFormValues('heatmap_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});



// -------------------------------------------------
// 共现性网络分析
document.getElementById('plot_button_cooccurrence_network').addEventListener('click', () => {
    const values = collectFormValues('cooccurrence_network_control_items'); // 调用函数并传入容器 ID
    console.log(values); // 输出到控制台以便调试
});

