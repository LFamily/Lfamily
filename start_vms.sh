#!/bin/bash

# 设置环境变量
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# 添加脚本说明
echo "开始启动所有虚拟机..."

# 定义虚拟机路径数组
VMS=(
    "/Users/liang/Library/Containers/com.utmapp.UTM/Data/Documents/iStoreOS.utm"
)

# 检查 UTM.app 是否存在
if [ ! -d "/Applications/UTM.app" ]; then
    echo "❌ UTM.app 未找到，请确保已正确安装"
    exit 1
fi

# 启动 UTM.app
echo "正在启动 UTM.app..."
osascript -e 'tell application "UTM" to activate'
sleep 2

# 遍历所有虚拟机并启动
for vm_path in "${VMS[@]}"; do
    if [ -d "$vm_path" ]; then
        echo "正在启动虚拟机: $vm_path"
        vm_name=$(basename "$vm_path" .utm)
        
        # 使用 AppleScript 启动虚拟机
        osascript <<EOT
tell application "UTM"
    try
        set vmList to every virtual machine
        repeat with vm in vmList
            if name of vm is "$vm_name" then
                if status of vm is not "started" then
                    start vm
                    delay 2
                end if
                exit repeat
            end if
        end repeat
    end try
end tell
EOT
        
        if [ $? -eq 0 ]; then
            echo "✅ 虚拟机 $vm_name 启动成功或已在运行"
        else
            echo "❌ 虚拟机 $vm_name 启动失败"
        fi
    else
        echo "⚠️  虚拟机路径不存在: $vm_path"
    fi
done

echo "所有虚拟机启动完成！"

# 显示所有运行中的虚拟机状态
echo -e "\n当前运行的虚拟机列表："
osascript <<EOT
tell application "UTM"
    set vmList to every virtual machine
    repeat with vm in vmList
        log (name of vm & " - " & status of vm)
    end repeat
end tell
EOT 