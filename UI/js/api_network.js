// 封装函数：调用 Network
async function NetworkAnalysis() {
    try {
        console.log("已提交信息：网络分析");

        // 获取 OTU, Tax 和 metadata 信息
        const featureData = sharedFeatureData;     // OTU
        const taxonomyData = sharedTaxonomyData;   // Tax
        const metadata = sharedMetadataData;       // Metadata

        // 获取分组参数
        const groupInformation1 = document.getElementById("cooccurrence_network_groupInformation1").value; // 获取实验分组1的值
        const parallelMethods = document.getElementById("cooccurrence_network_parallelMethods").value; // 获取平行样处理方法
        // const classification = document.getElementById("cooccurrence_network_classification").value; // 获取分类等级

        // 获取方法参数
        const calcMethod = document.getElementById("cooccurrence_network_calc_method").value; // 获取相关性算法
        const rValue = document.getElementById("cooccurrence_network_r").value; // 获取相关性阈值
        const pValue = document.getElementById("cooccurrence_network_p").value; // 获取显著性阈值
        const clusterMethod = document.getElementById("cooccurrence_network_cluster_method").value; // 获取聚类算法
        const normalize = document.getElementById("cooccurrence_network_normalize").value; // 获取标准化选项



        // 构建请求体
        const requestBody = {
            // 数据
            featureData,
            taxonomyData,
            metadata,

            // 分组信息
            groupInformation: {
                group: groupInformation1
            },

            // 平行样
            parallel: {
                parallel_method: parallelMethods
            },

            // 分类信息
            // classification: classification,

            // 方法参数
            calc_method: calcMethod,
            r: rValue,
            p: pValue,
            cluster_method: clusterMethod,
            normalize: normalize

        };



        // 发送请求
        const response = await fetch(`${apiBaseURL}/network`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        console.log("后端返回结果：", result);


        // 处理 HTML
        if (
            (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) ||
            (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) ||
            (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1)
        ) {
            if (Array.isArray(result.otu) && result.otu.length === 1 && result.otu[0] === -1) {
                console.warn("输入的 OTU 表为空");
                showToast("OTU 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.tax) && result.tax.length === 1 && result.tax[0] === -1) {
                console.warn("输入的 tax 表为空");
                showToast("Tax 表为空！", "error", "bottom-right");
            }
            if (Array.isArray(result.metadata) && result.metadata.length === 1 && result.metadata[0] === -1) {
                console.warn("输入的 metadata 表为空");
                showToast("Metadata file 为空！", "error", "bottom-right");
            }
        } else if (Array.isArray(result.metadata) && result.metadata.length === 1) {
            // 生成网络分析数据
            // 边数据
            cooccurrence_network_file_edge = result.edge;  // 从结果中提取边数据

            // 节点数据
            cooccurrence_network_file_node = result.node;  // 从结果中提取节点数据

            // 调用函数将这两个数据生成表格并赋值到下面的容器中
            generateOrUpdateTable(cooccurrence_network_file_edge, ["table_cooccurrence_network_edge"]);  // 生成边数据表格
            generateOrUpdateTable(cooccurrence_network_file_node, ["table_cooccurrence_network_node"]);  // 生成节点数据表格

            // 提示网络分析成功
            showToast("网络分析成功！", "success", "bottom-right");

        }
    } catch (error) {
        console.error("调用 /network 接口失败：", error);
        showToast("接口调用失败，请稍后重试", "error", "bottom-right");
    }
}


// 绑定点击事件，调用封装的函数
document.getElementById("plot_button_cooccurrence_network").addEventListener("click", NetworkAnalysis);
