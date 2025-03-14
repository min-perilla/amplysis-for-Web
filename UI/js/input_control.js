// 更新输入框的值，确保在指定范围内
function updateInputValue(inputId, minValue, maxValue) {
    // 获取输入框元素
    const inputElement = document.getElementById(inputId);

    // 添加失去焦点事件监听器
    inputElement.addEventListener('blur', () => {
        // 检查输入框是否为空
        if (inputElement.value === '') {
            inputElement.value = minValue; // 如果为空，重置为最小值
        }

        // 获取输入值
        let value = parseFloat(inputElement.value);

        // 限制范围
        if (value < minValue) {
            value = minValue; // 最小值
        } else if (value > maxValue) {
            value = maxValue; // 最大值
        }

        // 更新输入框的值
        inputElement.value = value;

        // 输出结果，确保在值更新后进行输出
        console.log(value);
    });
}
