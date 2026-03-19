#!/bin/sh

# PPPoE 默认拨号配置
# 注意：请修改下面的账号和密码为你的实际宽带账号密码
# 如果不想使用自动配置，请删除此文件或留空账号密码

PPPOE_USERNAME="你的宽带账号"
PPPOE_PASSWORD="你的宽带密码"

# 只有当账号密码被修改后才配置
if [ "$PPPOE_USERNAME" != "你的宽带账号" ] && [ "$PPPOE_PASSWORD" != "你的宽带密码" ]; then
    echo "正在配置 PPPoE 拨号..."
    
    # 配置 WAN 接口为 PPPoE 拨号
    uci set network.wan.proto='pppoe'
    uci set network.wan.username="$PPPOE_USERNAME"
    uci set network.wan.password="$PPPOE_PASSWORD"
    
    # 设置开机自动拨号
    uci set network.wan.auto='1'
    
    # 保存配置
    uci commit network
    
    echo "PPPoE 配置已完成，账号：$PPPOE_USERNAME"
else
    echo "未检测到 PPPoE 账号密码配置，跳过自动设置"
fi

