#!/bin/bash

# 构建和推送 Buf plugin 脚本

set -e

# 配置变量
PLUGIN_NAME="buf.build/liuyuqiang/protogentag"
PLUGIN_VERSION="v1.0.4"
DOCKER_IMAGE="${PLUGIN_NAME}:${PLUGIN_VERSION}"

echo "构建 Docker 镜像: ${DOCKER_IMAGE}"

# 构建 Docker 镜像
docker build --platform linux/amd64 -t "${DOCKER_IMAGE}" .

echo "Docker 镜像构建完成"

# 检查是否要推送到 BSR
if [ "$1" = "--push" ]; then
    echo "推送插件到 BSR..."
    
    # 检查是否已登录 BSR，如果没有则自动登录
    if ! buf registry whoami >/dev/null 2>&1; then
        echo "未检测到 BSR 登录状态，正在自动登录..."
        echo "请按照提示完成登录流程"
        buf registry login buf.build
        if [ $? -ne 0 ]; then
            echo "❌ BSR 登录失败"
            exit 1
        fi
        echo "✅ BSR 登录成功"
    else
        echo "✅ 已登录 BSR"
    fi
    
    # 推送插件
    echo "正在推送插件..."
    echo "插件名称: ${PLUGIN_NAME}"
    echo "镜像名称: ${DOCKER_IMAGE}"
    
    # 设置环境变量抑制警告
    export BUF_BETA_SUPPRESS_WARNINGS=1
    
    # 尝试使用新的 beta 命令推送
    echo "尝试使用新的 beta 命令推送..."
    buf beta registry plugin push \
        --visibility public \
        --image "${DOCKER_IMAGE}"
    
    if [ $? -eq 0 ]; then
        echo "✅ 插件推送完成: ${PLUGIN_NAME}:${PLUGIN_VERSION}"
    else
        echo "❌ 插件推送失败"
        echo ""
        echo "可能的解决方案："
        echo "1. 检查 BSR 权限设置"
        echo "2. 联系 Buf 支持团队获取插件推送权限"
        echo "3. 查看 BSR_PLUGIN_GUIDE.md 获取详细说明"
        exit 1
    fi
else
    echo "🚀 Buf Plugin 构建脚本"
    echo ""
    echo "用法："
    echo "  $0                    # 仅构建 Docker 镜像"
    echo "  $0 --push            # 构建并推送到 BSR（自动登录）"
    echo ""
    echo "插件信息："
    echo "  名称: ${PLUGIN_NAME}"
    echo "  版本: ${PLUGIN_VERSION}"
    echo "  镜像: ${DOCKER_IMAGE}"
    echo ""
    echo "如果遇到推送问题，请查看 BSR_PLUGIN_GUIDE.md 获取详细说明"
fi
