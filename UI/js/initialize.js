// 初始化全局变量

// api 端口
const apiBaseURL = "http://127.0.0.1:8000"; // 定义后端 API 的基础 URL



// ------------------------------------------------------------------------------------------------
// 图形
let species_stack_svg = null; // 存放 SVG 图像，初始化为 null，等待后续赋值
// let chord_diagram_svg = null;
let venn_svg = null;
let upset_svg = null;

let boxplot_svg = {
    shannon: null,
    simpson: null,
    chao1: null,
    ace: null,
    pielou: null,
    goods_coverage: null,
    pd: null
};

let pca_svg = null;
let pcoa_svg = null;
let nmds_svg = null;
let rda_svg = null;
let cca_svg = null;

let heatmap_svg = null;

// 数据表格
let cooccurrence_network_file_edge = null  // 网络分析边文件
let cooccurrence_network_file_node = null  // 网络分析节点文件


let exportFile_Width = null;   // 存放导出文件的宽度
let exportFile_Height = null;  // 存放导出文件的高度



// 初始化函数
function initializeSpeciesStackSVG() {

    // 明确初始化为 null
    species_stack_svg = null;
    // chord_diagram_svg = null;
    venn_svg = null;
    upset_svg = null;

    boxplot_svg = {
        shannon: null,
        simpson: null,
        chao1: null,
        ace: null,
        pielou: null,
        goods_coverage: null,
        pd: null
    };

    pca_svg = null;
    pcoa_svg = null;
    nmds_svg = null
    rda_svg = null
    cca_svg = null

    heatmap_svg = null

    cooccurrence_network_file_edge = null  // 网络分析边文件
    cooccurrence_network_file_node = null  // 网络分析节点文件

    exportFile_Width = null;
    exportFile_Height = null;
}

// 在脚本加载时调用初始化函数
initializeSpeciesStackSVG();




// ------------------------------------------------------------------------------------------------
// 创建表格：creatTable.js
let sharedFeatureData = null; // 全局变量，用于存储特征表数据
let sharedTaxonomyData = null; // 全局变量，用于存储分类表数据
let sharedRepSeqsData = null; // 全局变量，用于存储代表性序列数据
let sharedMetadataData = null; // 全局变量，用于存储样本元数据
let sharedTreeData = null; // 全局变量，用于存储系统发育树数据
let sharedEnvData = null; // 全局变量，用于存储环境因子数据

let sharedFeatureData_backup = null; // 全局变量，用于备份数据分列前的特征表数据
let sharedTaxonomyData_backup = null; // 全局变量，用于备份数据分列前的分类表数据
let sharedRepSeqsData_backup = null; // 全局变量，用于备份数据分列前的代表性序列数据

// 定义上传状态变量，初始值为 false
let isFeatureTableUploaded = false; // 表示特征表文件是否上传
let isTaxonomyTableUploaded = false; // 表示分类表文件是否上传
let isRepSeqsUploaded = false; // 表示代表性序列文件是否上传
let isMetadataUploaded = false; // 表示样本元数据文件是否上传
let isTreeUploaded = false; // 表示系统发育树文件是否上传
let isEnvUploaded = false; // 表示环境因子是否上传

// 初始化函数
function initializeGlobalVariables() {
    sharedFeatureData = null;
    sharedTaxonomyData = null;
    sharedRepSeqsData = null;
    sharedMetadataData = null;
    sharedTreeData = null;
    sharedEnvData = null;

    sharedFeatureData_backup = null;
    sharedTaxonomyData_backup = null;
    sharedRepSeqsData_backup = null

    isFeatureTableUploaded = false;
    isTaxonomyTableUploaded = false;
    isRepSeqsUploaded = false;
    isMetadataUploaded = false;
    isTreeUploaded = false;
    isEnvUploaded = false;
}

// 在脚本加载时调用初始化函数
initializeGlobalVariables();




// ------------------------------------------------------------------------------------------------
// 重置文件：initialize.js

let preprocessing_rarefy_is_otu_backup = false; // OTU 备份标志
let preprocessing_rarefy_is_tax_backup = false; // tax 备份标志
let preprocessing_rarefy_is_rep_backup = false; // rep 备份标志

// 初始化函数
function initializeBackupFlags() {
    preprocessing_rarefy_is_otu_backup = false; // 初始化为 false
    preprocessing_rarefy_is_tax_backup = false; // 初始化为 false
    preprocessing_rarefy_is_rep_backup = false; // 初始化为 false
}

// 在脚本加载时调用初始化函数
initializeBackupFlags();


// ------------------
// 备份标志对象初始化
let taxBackupStatus = {
    separate: false,     // 数据分列
    trimPrefix: false,   // 去前缀
    namesRepair: false,  // 修复
};

// 初始化函数
function initializeTaxBackupStatus() {
    taxBackupStatus = {
        separate: false,     // 数据分列
        trimPrefix: false,   // 去前缀
        namesRepair: false,  // 修复
    };

}

// 在脚本加载时调用初始化函数
initializeTaxBackupStatus();

