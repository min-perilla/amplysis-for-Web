//  画布的“宽度”、“高度”与导出文件的“宽度”、“高度”同步

// 定义一个同步值的函数
function bindValues(inputId1, inputId2) {
    const input1 = document.getElementById(inputId1);
    const input2 = document.getElementById(inputId2);

    if (!input1 || !input2) {
        console.error(`Element(s) with ID(s) '${inputId1}' or '${inputId2}' not found.`);
        return;
    }

    // 更新另一个输入框的值
    function syncValue(event) {
        const newValue = event.target.value;
        input1.value = newValue;
        input2.value = newValue;
    }

    // 为两个输入框添加事件监听
    input1.addEventListener("input", syncValue);
    input2.addEventListener("input", syncValue);
}


// 调用绑定函数，添加 DOMContentLoaded 事件监听器
document.addEventListener("DOMContentLoaded", function () {

    // 物种堆叠图
    // 同步宽度
    bindValues("species_stack_exportWidth", "species_stack_canvasWidth");
    // 同步高度
    bindValues("species_stack_exportHeight", "species_stack_canvasHeight");


    // // 弦图
    // bindValues("chord_diagram_exportWidth", "chord_diagram_canvasWidth");
    // // 同步高度
    // bindValues("chord_diagram_exportHeight", "chord_diagram_canvasHeight");


    // venn 图
    // 同步宽度
    bindValues("venn_exportWidth", "venn_canvasWidth");
    // 同步高度
    bindValues("venn_exportHeight", "venn_canvasHeight");


    // 集合图
    // 同步宽度
    bindValues("upset_exportWidth", "upset_canvasWidth");
    // 同步高度
    bindValues("upset_exportHeight", "upset_canvasHeight");


    // 箱线图
    bindValues("boxplot_exportWidth", "boxplot_canvasWidth");
    // 同步高度
    bindValues("boxplot_exportHeight", "boxplot_canvasHeight");
    

    // PCA
    // 同步宽度
    bindValues("pca_exportWidth", "pca_canvasWidth");
    // 同步高度
    bindValues("pca_exportHeight", "pca_canvasHeight");


    // PCoA
    // 同步宽度
    bindValues("pcoa_exportWidth", "pcoa_canvasWidth");
    // 同步高度
    bindValues("pcoa_exportHeight", "pcoa_canvasHeight");


    // NMDS
    // 同步宽度
    bindValues("nmds_exportWidth", "nmds_canvasWidth");
    // 同步高度
    bindValues("nmds_exportHeight", "nmds_canvasHeight");


    // RDA
    // 同步宽度
    bindValues("rda_exportWidth", "rda_canvasWidth");
    // 同步高度
    bindValues("rda_exportHeight", "rda_canvasHeight");


    // CCA
    bindValues("cca_exportWidth", "cca_canvasWidth");
    // 同步高度
    bindValues("cca_exportHeight", "cca_canvasHeight");

    
    // 热图
    bindValues("heatmap_exportWidth", "heatmap_canvasWidth");
    // 同步高度
    bindValues("heatmap_exportHeight", "heatmap_canvasHeight");


    // 共现性网络分析
});
