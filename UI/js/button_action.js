// 为按钮设置“选中”样式的通用函数
function setActiveButton(buttons, defaultIndex = 0) {
    // 检查按钮组是否为空
    if (buttons.length > 0) {
        // 根据传入的索引将默认按钮设置为选中状态
        buttons[defaultIndex].setAttribute('id', 'action');
    }

    // 遍历按钮组，为每个按钮添加点击事件监听器
    buttons.forEach(button => {
        button.addEventListener('click', function () {
            // 点击时先移除所有按钮的 'action' id
            buttons.forEach(btn => btn.removeAttribute('id'));

            // 将当前点击的按钮设置为选中状态
            this.setAttribute('id', 'action');
        });
    });
}




// 等整个文档内容加载完成后执行代码
document.addEventListener('DOMContentLoaded', () => {

    // ==================== 侧边栏功能菜单的按钮逻辑 ====================

    // 获取功能菜单中的所有按钮
    const allMenuButtons = document.querySelectorAll('#subBar .menu_group button');

    // 找到“数据导入”按钮，并确定它在按钮组中的索引
    const defaultMenuButton = document.querySelector('a[data-target="view_data_import"] button');
    const defaultMenuIndex = Array.from(allMenuButtons).indexOf(defaultMenuButton);

    // 调用通用函数为功能菜单按钮添加“选中”样式
    setActiveButton(allMenuButtons, defaultMenuIndex);



    // ==================== 导航栏的按钮逻辑 ====================

    // 数据导入页面导航栏
    // 获取数据导入页面的导航栏按钮
    const NavButtons_dataImport = document.querySelectorAll('#preview_nav .button_nav');
    // 为数据导入导航栏的按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(NavButtons_dataImport);


    // 数据预处理页面导航栏
    // 获取数据预处理页面的导航栏按钮
    const NavButtons_preprocessing = document.querySelectorAll('#preprocessing_nav .button_nav');
    // 为数据预处理导航栏的按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(NavButtons_preprocessing);


    // "箱线图"页面导航栏
    // 获取箱线图页面的导航栏按钮
    const NavButtons_boxplot = document.querySelectorAll('#boxplot_nav .button_nav');
    // 为箱线图导航栏的按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(NavButtons_boxplot);


    // "网络图"页面导航栏
    // 获取网络图页面的导航栏按钮
    const NavButtons_cooccurrence_network = document.querySelectorAll('#cooccurrence_network_nav .button_nav');
    // 为网络图导航栏的按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(NavButtons_cooccurrence_network);



    // ==================== 控制菜单按钮逻辑 ====================

    // “数据预处理”控制菜单按钮
    // 获取数据预处理“OTU数据抽平”属性控制菜单中的所有按钮
    const controlMenu_preprocessing_raref = document.querySelectorAll(
        '#control_group_items_preprocessing_rarefy .control_nav_button'
    );
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_preprocessing_raref);



    // 获取数据预处理“tax表分列”属性控制菜单中的所有按钮
    const controlMenu_preprocessing_separate = document.querySelectorAll(
        '#control_group_items_preprocessing_separate .control_nav_button'
    );
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_preprocessing_separate);



    // 获取数据预处理“tax表去前缀”属性控制菜单中的所有按钮
    const controlMenu_preprocessing_prefix = document.querySelectorAll(
        '#control_group_items_preprocessing_prefix .control_nav_button'
    );
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_preprocessing_prefix);



    // 获取数据预处理“tax表修复”属性控制菜单中的所有按钮
    const controlMenu_preprocessing_repair = document.querySelectorAll(
        '#control_group_items_preprocessing_repair .control_nav_button'
    );
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_preprocessing_repair);













    // ----------------------------------------------------------
    // “物种堆叠图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_speciesStack = document.querySelectorAll('#content_species_stack .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_speciesStack);



    // // ----------------------------------------------------------
    // // “弦图”控制菜单按钮
    // // 获取数据预处理页面的控制菜单按钮
    // const controlMenu_chord_diagram = document.querySelectorAll('#content_chord_diagram .control_nav_button');
    // // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    // setActiveButton(controlMenu_chord_diagram);



    // ----------------------------------------------------------
    // “韦恩图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_venn = document.querySelectorAll('#content_venn .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_venn);



    // ----------------------------------------------------------
    // “集合图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_upset = document.querySelectorAll('#content_upset .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_upset);



    // ----------------------------------------------------------
    // “箱线图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_boxplot = document.querySelectorAll('#content_boxplot .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_boxplot);



    // ----------------------------------------------------------
    // “PCA”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_pca = document.querySelectorAll('#content_pca .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_pca);



    // ----------------------------------------------------------
    // “PCoA”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_pcoa = document.querySelectorAll('#content_pcoa .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_pcoa);



    // ----------------------------------------------------------
    // “NMDS”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_nmds = document.querySelectorAll('#content_nmds .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_nmds);



    // ----------------------------------------------------------
    // “RDA”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_rda = document.querySelectorAll('#content_rda .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_rda);



    // ----------------------------------------------------------
    // “CCA”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_cca = document.querySelectorAll('#content_cca .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_cca);



    // ----------------------------------------------------------
    // “热图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_heatmap = document.querySelectorAll('#content_heatmap .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_heatmap);



    // ----------------------------------------------------------
    // “共现性网络分析图”控制菜单按钮
    // 获取数据预处理页面的控制菜单按钮
    const controlMenu_cooccurrence_network = document.querySelectorAll('#content_cooccurrence_network .control_nav_button');
    // 为控制菜单按钮添加“选中”样式（默认第一个按钮）
    setActiveButton(controlMenu_cooccurrence_network);



});
