/**
 * 初始化颜色选择器功能
 * @param {string} selectId - 颜色选择器 <input type="color"> 的 ID
 * @param {string} addButtonId - 添加颜色按钮的 ID
 * @param {string} numberInputId - 输入生成随机颜色数量的 <input type="number"> 的 ID
 * @param {string} generatorButtonId - 随机生成颜色按钮的 ID
 * @param {string} textOutputId - 显示最终颜色值的文本框 <input type="text"> 的 ID
 */
function initColorPicker(selectId, addButtonId, numberInputId, generatorButtonId, textOutputId) {
    // 通过传入的 ID 获取 HTML 元素
    const colorSelect = document.getElementById(selectId);  // 颜色选择器
    const colorAddButton = document.getElementById(addButtonId);  // 添加颜色的按钮
    const colorNumberInput = document.getElementById(numberInputId);  // 输入生成颜色数量的输入框
    const colorGeneratorButton = document.getElementById(generatorButtonId);  // 生成颜色的按钮
    const colorText = document.getElementById(textOutputId);  // 显示生成颜色的文本框

    // 存储已添加颜色的数组
    let colors = [];

    // 当用户点击“添加”按钮时，将当前选中的颜色添加到颜色列表中
    colorAddButton.addEventListener('click', function () {
        const selectedColor = colorSelect.value;  // 获取当前选中的颜色值
        colors.push(selectedColor);  // 将颜色添加到数组中
        colorText.value = colors.join(', ');  // 将数组中的颜色用逗号拼接并显示在文本框中
    });

    // 随机生成一个颜色值，返回格式为 #RRGGBB 的十六进制字符串
    function generateRandomColor() {
        // Math.random() 生成 0-1 的随机数；乘以 16777215 即 0xFFFFFF 转成 16 进制，再补齐6位
        return '#' + Math.floor(Math.random() * 16777215).toString(16).padStart(6, '0');
    }

    // 当用户点击“生成”按钮时，生成随机颜色并更新颜色文本框
    colorGeneratorButton.addEventListener('click', function () {
        const colorCount = parseInt(colorNumberInput.value) || 1;  // 从输入框获取要生成的颜色数量，默认为 1
        colors = [];  // 重置颜色数组，清空之前的颜色记录

        // 循环生成指定数量的随机颜色
        for (let i = 0; i < colorCount; i++) {
            colors.push(generateRandomColor());  // 调用生成随机颜色函数，并添加到数组中
        }

        colorText.value = colors.join(', ');  // 将生成的颜色用逗号分隔，更新到文本框中显示
    });

    // 当用户手动清空文本框时，同步清空数组 colors
    colorText.addEventListener('input', function () {
        if (colorText.value.trim() === '') {
            colors = [];  // 清空数组
        }
    });
}


// ----------------------------------------------------
// “物种堆叠图”
// 使用示例：调用 initColorPicker 初始化颜色选择器功能
initColorPicker(
    'species_stack_colorSelect',           // 颜色选择器的 ID
    'species_stack_colorAddButton',        // 添加颜色按钮的 ID
    'species_stack_colorNumber',           // 随机生成颜色数量输入框的 ID
    'species_stack_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'species_stack_colorText'              // 显示颜色列表的文本框 ID
);



// // ----------------------------------------------------
// // “弦图”
// initColorPicker(
//     'chord_diagram_colorSelect',           // 颜色选择器的 ID
//     'chord_diagram_colorAddButton',        // 添加颜色按钮的 ID
//     'chord_diagram_colorNumber',           // 随机生成颜色数量输入框的 ID
//     'chord_diagram_colorGeneratorButton',  // 随机生成颜色按钮的 ID
//     'chord_diagram_colorText'              // 显示颜色列表的文本框 ID
// );



// ----------------------------------------------------
// “韦恩图”
initColorPicker(
    'venn_colorSelect',           // 颜色选择器的 ID
    'venn_colorAddButton',        // 添加颜色按钮的 ID
    'venn_colorNumber',           // 随机生成颜色数量输入框的 ID
    'venn_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'venn_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “集合图”
initColorPicker(
    'upset_colorSelect',           // 颜色选择器的 ID
    'upset_colorAddButton',        // 添加颜色按钮的 ID
    'upset_colorNumber',           // 随机生成颜色数量输入框的 ID
    'upset_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'upset_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “箱线图”
initColorPicker(
    'boxplot_colorSelect',           // 颜色选择器的 ID
    'boxplot_colorAddButton',        // 添加颜色按钮的 ID
    'boxplot_colorNumber',           // 随机生成颜色数量输入框的 ID
    'boxplot_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'boxplot_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “PCA”
initColorPicker(
    'pca_colorSelect',           // 颜色选择器的 ID
    'pca_colorAddButton',        // 添加颜色按钮的 ID
    'pca_colorNumber',           // 随机生成颜色数量输入框的 ID
    'pca_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'pca_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “PCoA”
initColorPicker(
    'pcoa_colorSelect',           // 颜色选择器的 ID
    'pcoa_colorAddButton',        // 添加颜色按钮的 ID
    'pcoa_colorNumber',           // 随机生成颜色数量输入框的 ID
    'pcoa_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'pcoa_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “NMDS”
initColorPicker(
    'nmds_colorSelect',           // 颜色选择器的 ID
    'nmds_colorAddButton',        // 添加颜色按钮的 ID
    'nmds_colorNumber',           // 随机生成颜色数量输入框的 ID
    'nmds_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'nmds_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “RDA”
initColorPicker(
    'rda_colorSelect',           // 颜色选择器的 ID
    'rda_colorAddButton',        // 添加颜色按钮的 ID
    'rda_colorNumber',           // 随机生成颜色数量输入框的 ID
    'rda_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'rda_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “CCA”
initColorPicker(
    'cca_colorSelect',           // 颜色选择器的 ID
    'cca_colorAddButton',        // 添加颜色按钮的 ID
    'cca_colorNumber',           // 随机生成颜色数量输入框的 ID
    'cca_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'cca_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// “热图”
initColorPicker(
    'heatmap_colorSelect',           // 颜色选择器的 ID
    'heatmap_colorAddButton',        // 添加颜色按钮的 ID
    'heatmap_colorNumber',           // 随机生成颜色数量输入框的 ID
    'heatmap_colorGeneratorButton',  // 随机生成颜色按钮的 ID
    'heatmap_colorText'              // 显示颜色列表的文本框 ID
);



// ----------------------------------------------------
// // “共现性网络分析”
// initColorPicker(
//     'cooccurrence_network_colorSelect',           // 颜色选择器的 ID
//     'cooccurrence_network_colorAddButton',        // 添加颜色按钮的 ID
//     'cooccurrence_network_colorNumber',           // 随机生成颜色数量输入框的 ID
//     'cooccurrence_network_colorGeneratorButton',  // 随机生成颜色按钮的 ID
//     'cooccurrence_network_colorText'              // 显示颜色列表的文本框 ID
// );
