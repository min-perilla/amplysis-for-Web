function showToast(message, type = "info", position = "bottom-right") {
    let toastContainer = document.getElementById("toastContainer");

    // 如果容器不存在，创建一个
    if (!toastContainer) {
        toastContainer = document.createElement("div");
        toastContainer.id = "toastContainer";

        // 设置容器位置样式
        toastContainer.style.position = "fixed"; // 固定在页面上
        toastContainer.style.zIndex = "1000"; // 保证弹窗在最前
        toastContainer.style.display = "flex"; // 使用 flex 布局
        toastContainer.style.flexDirection = "column-reverse"; // 新的弹窗出现在最下方

        // 根据位置参数设置容器的位置
        if (position === "top-right") {
            toastContainer.style.top = "10px";
            toastContainer.style.right = "10px";
        } else if (position === "bottom-right") {
            toastContainer.style.bottom = "10px";
            toastContainer.style.right = "10px";
        } else {
            console.warn("Invalid position. Defaulting to bottom-right."); // 默认位置为右下角
            toastContainer.style.bottom = "10px";
            toastContainer.style.right = "10px";
        }

        // 将容器添加到页面中
        document.body.appendChild(toastContainer);
    }

    // 创建单个弹窗元素
    const toast = document.createElement("div");
    toast.textContent = message; // 设置弹窗显示的文本内容

    // 设置弹窗样式
    toast.style.marginTop = "10px"; // 设置顶部外边距，避免弹窗之间重叠
    toast.style.padding = "12px 30px"; // 内边距，提供视觉舒适的空间
    toast.style.borderRadius = "12px"; // 圆角边框
    toast.style.color = "white"; // 文本颜色为白色
    toast.style.fontSize = "18px"; // 字体大小
    toast.style.boxShadow = "0 4px 8px rgba(0, 0, 0, 0.3)"; // 阴影，提升视觉效果

    // 修复上下左右居中
    toast.style.display = "flex"; // 使用 flex 布局
    toast.style.justifyContent = "center"; // 水平居中
    toast.style.alignItems = "center"; // 垂直居中

    // 初始动画状态（从屏幕右边进入）
    toast.style.transform = "translateX(100%)"; 
    toast.style.opacity = "0"; // 初始透明度为 0
    toast.style.transition = "transform 0.6s cubic-bezier(0.25, 1, 0.5, 1), opacity 0.6s ease-out"; // 平滑过渡动画

    // 固定高度，保证所有弹窗一致
    toast.style.height = "60px";

    // 根据弹窗类型设置背景颜色
    switch (type) {
        case "success":
            toast.style.backgroundColor = "#28a745"; // 成功弹窗为绿色
            break;
        case "error":
            toast.style.backgroundColor = "#dc3545"; // 错误弹窗为红色
            break;
        default:
            toast.style.backgroundColor = "#007bff"; // 默认弹窗为蓝色
            break;
    }

    // 将弹窗插入到容器顶部
    toastContainer.prepend(toast);

    // 触发动画（从屏幕右边滑入）
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            toast.style.transform = "translateX(0)"; // 还原到屏幕内位置
            toast.style.opacity = "1"; // 设置为完全不透明
        });
    });

    // 等待后移除弹窗（滑出动画）
    setTimeout(() => {
        toast.style.transform = "translateX(100%)"; // 向右滑出屏幕
        toast.style.opacity = "0"; // 设置为完全透明
        toast.addEventListener("transitionend", () => toast.remove()); // 动画结束后移除元素
    }, 2500);
}
