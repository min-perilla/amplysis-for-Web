// "数据导入"界面“选择文件”视图

// 当 DOM 内容加载完成后执行这个函数
document.addEventListener('DOMContentLoaded', () => {
    // 为每一个带有 .table_control_input 类的文件输入框添加事件监听器
    document.querySelectorAll('.table_control_input').forEach(input => {
        
        // 当文件选择框发生变化（即用户选择或取消选择文件）时执行的事件处理函数
        input.addEventListener('change', function() {
            // 获取当前文件输入框对应的父元素，它的类是 .table_control_item
            // 通过 .closest 方法从当前 input 向上查找最近的父级元素
            const controlItem = this.closest('.table_control_item');
            
            // 检查当前输入框是否有文件被选择（this.files 是一个文件列表，若长度大于 0 表示有文件）
            if (this.files.length > 0) {
                // 如果有文件被选择，为父元素添加 .active 类，触发背景颜色的动画
                controlItem.classList.add('active');
            } else {
                // 如果没有文件被选择（文件被取消），移除父元素的 .active 类，恢复初始背景色
                controlItem.classList.remove('active');
            }
        });
    });
});
