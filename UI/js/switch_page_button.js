// 各 a 标签按钮切换视图功能

// 封装成函数 1
// data-target
function setupMenuToggle(menuSelector, pageSelector, defaultPageId) {
    // 绑定菜单栏点击事件处理程序
    $(menuSelector).click(function () {
        var target = $(this).data('target');

        // 隐藏所有页面
        $(pageSelector).hide();

        // 显示目标页面
        $('#' + target).show();
    });

    // 显示默认页面
    if (defaultPageId) {
        // 隐藏所有页面
        $(pageSelector).hide();
        // 显示默认页面
        $('#' + defaultPageId).show();
    }
}


// ----------------------------------------------------------------------
// 封装成函数 2
// data-target-2
function setupMenuToggle_2(menuSelector, pageSelector, defaultPageId) {
    // 绑定菜单栏点击事件处理程序
    $(menuSelector).click(function () {
        var target = $(this).data('target-2');

        // 隐藏所有页面
        $(pageSelector).hide();

        // 显示目标页面
        $('#' + target).show();
    });

    // 显示默认页面
    if (defaultPageId) {
        // 隐藏所有页面
        $(pageSelector).hide();
        // 显示默认页面
        $('#' + defaultPageId).show();
    }
}
// ----------------------------------------------------------------------








// 调用函数，传入选择器
// 侧边栏
$(document).ready(function () {
    setupMenuToggle(
        menuSelector = "#subBar .menu .menu_group a",
        pageSelector = '#content .view',
        defaultPageId = 'view_data_import'
    );
});


// “数据导入”页面导航栏按钮
// 控制表格切换
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preview_nav .table_nav_list a",
        // 要隐藏的页面
        '#preview_nav .table_container .table_page',
        // 默认的页面
        'feature_table_container')
});



// --------------------------------------------------------
// “数据预处理”页面导航栏按钮
// 控制表格切换
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preprocessing_nav .table_nav_list a",
        // 要隐藏的页面
        '#preprocessing_nav .table_container .table_page',
        // 默认的页面
        'feature_table_container_preprocessing')
});
// ----------------------------------------------------------------------------
// 控制“控制菜单”切换
$(document).ready(function () {
    setupMenuToggle_2(
        // a 标签按钮
        "#preprocessing_nav .table_nav_list a",
        // 要隐藏的页面
        '#content_preprocessing .control_group_container .page2',
        // 默认的页面
        'control_group_items_preprocessing_rarefy')
});
// -----------------------------------------------------------------------------



// “数据预处理” OTU数据抽平 控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preprocessing_rarefy_sidebar_button a",
        // 要隐藏的页面
        '#preprocessing_rarefy_control_items .page_preprocessing_rarefy',
        // 默认的页面
        'preprocessing_rarefy_control_attribute')
});


// “数据预处理” tax表分列 控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preprocessing_separate_sidebar_button a",
        // 要隐藏的页面
        '#preprocessing_separate_control_items .page_preprocessing_separate',
        // 默认的页面
        'preprocessing_separate_control_attribute')
});


// “数据预处理” tax表去前缀 控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preprocessing_prefix_sidebar_button a",
        // 要隐藏的页面
        '#preprocessing_prefix_control_items .page_preprocessing_prefix',
        // 默认的页面
        'preprocessing_prefix_control_attribute')
});


// “数据预处理” tax表修复 控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#preprocessing_repair_sidebar_button a",
        // 要隐藏的页面
        '#preprocessing_repair_control_items .page_preprocessing_repair',
        // 默认的页面
        'preprocessing_repair_control_attribute')
});









// --------------------------------------------------------
// “物种堆叠图”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_species_stack .control_nav_container a",
        // 要隐藏的页面
        '#content_species_stack .control_items_container .page',
        // 默认的页面
        'species_stack_control_groups')
});



// // --------------------------------------------------------
// // “弦图”控制菜单按钮
// $(document).ready(function () {
//     setupMenuToggle(
//         // a 标签按钮
//         "#content_chord_diagram .control_nav_container a",
//         // 要隐藏的页面
//         '#content_chord_diagram .control_items_container .page',
//         // 默认的页面
//         'chord_diagram_control_groups')
// });



// --------------------------------------------------------
// “韦恩图”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_venn .control_nav_container a",
        // 要隐藏的页面
        '#content_venn .control_items_container .page',
        // 默认的页面
        'venn_control_groups')
});



// --------------------------------------------------------
// “集合图”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_upset .control_nav_container a",
        // 要隐藏的页面
        '#content_upset .control_items_container .page',
        // 默认的页面
        'upset_control_groups')
});



// --------------------------------------------------------
function setupMenuToggle_plot(menuSelector, pageSelector, defaultPageId) {
    // 绑定菜单栏点击事件处理程序
    $(menuSelector).click(function () {
        var target = $(this).data('target');

        // 隐藏所有页面
        $(pageSelector).removeClass('active'); // 改为使用 active 类来控制显示

        // 显示目标页面
        $('#' + target).addClass('active'); // 通过类名控制显示
    });

    // 显示默认页面
    if (defaultPageId) {
        // 隐藏所有页面
        $(pageSelector).removeClass('active');
        // 显示默认页面
        $('#' + defaultPageId).addClass('active');
    }
}

// “箱线图”页面导航栏按钮
$(document).ready(function () {
    setupMenuToggle_plot(
        "#boxplot_nav .table_nav_list a", // a 标签按钮
        '#boxplot_nav .plot_container_nav .plot_page', // 要隐藏的页面
        'plot_boxplot_shannon' // 默认的页面
    );
});



// “箱线图”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_boxplot .control_nav_container a",
        // 要隐藏的页面
        '#content_boxplot .control_items_container .page',
        // 默认的页面
        'boxplot_control_groups')
});



// --------------------------------------------------------
// “PCA”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_pca .control_nav_container a",
        // 要隐藏的页面
        '#content_pca .control_items_container .page',
        // 默认的页面
        'pca_control_groups')
});



// --------------------------------------------------------
// “PCoA”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_pcoa .control_nav_container a",
        // 要隐藏的页面
        '#content_pcoa .control_items_container .page',
        // 默认的页面
        'pcoa_control_groups')
});



// --------------------------------------------------------
// “NMDS”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_nmds .control_nav_container a",
        // 要隐藏的页面
        '#content_nmds .control_items_container .page',
        // 默认的页面
        'nmds_control_groups')
});



// --------------------------------------------------------
// “RDA”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_rda .control_nav_container a",
        // 要隐藏的页面
        '#content_rda .control_items_container .page',
        // 默认的页面
        'rda_control_groups')
});



// --------------------------------------------------------
// “CCA”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_cca .control_nav_container a",
        // 要隐藏的页面
        '#content_cca .control_items_container .page',
        // 默认的页面
        'cca_control_groups')
});



// --------------------------------------------------------
// “热图”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_heatmap .control_nav_container a",
        // 要隐藏的页面
        '#content_heatmap .control_items_container .page',
        // 默认的页面
        'heatmap_control_groups')
});



// --------------------------------------------------------
// “共现性网络分析”页面导航栏按钮
// 控制表格切换
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#cooccurrence_network_nav .table_nav_list a",
        // 要隐藏的页面
        '#cooccurrence_network_nav .table_container .table_page',
        // 默认的页面
        'table_cooccurrence_network_edge')
});

// “共现性网络分析”控制菜单按钮
$(document).ready(function () {
    setupMenuToggle(
        // a 标签按钮
        "#content_cooccurrence_network .control_nav_container a",
        // 要隐藏的页面
        '#content_cooccurrence_network .control_items_container .page',
        // 默认的页面
        'cooccurrence_network_control_groups')
});
