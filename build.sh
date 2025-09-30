#!/bin/bash

# 构建和推送 Buf plugin 脚本

set -e

# 配置变量
PLUGIN_NAME="buf.build/liuyuqiang/protogentag"
PLUGIN_VERSION="${PLUGIN_VERSION:-v1.0.4}"
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
        echo "✅ 已登录 BSR: $(buf registry whoami)"
    fi
    
    # 检查组织权限
    echo "检查组织权限..."
    if ! buf registry organization info buf.build/liuyuqiang >/dev/null 2>&1; then
        echo "❌ 无法访问组织 buf.build/liuyuqiang"
        echo "请确保你有该组织的管理员权限"
        exit 1
    fi
    echo "✅ 组织权限检查通过"
    
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
    
    PUSH_EXIT_CODE=$?
    
    if [ $PUSH_EXIT_CODE -eq 0 ]; then
        echo "✅ 插件推送完成: ${PLUGIN_NAME}:${PLUGIN_VERSION}"
    else
        echo "❌ 插件推送失败 (退出码: $PUSH_EXIT_CODE)"
        echo ""
        echo "可能的解决方案："
        echo "1. 确保你有 liuyuqiang 组织的管理员权限"
        echo "2. 检查 Docker 镜像是否正确构建和标记"
        echo "3. 尝试手动推送 Docker 镜像到 Docker Hub 或 Quay"
        echo "4. 联系 Buf 支持团队获取插件推送权限"
        echo "5. 查看 BSR_PLUGIN_GUIDE.md 获取详细说明"
        echo ""
        echo "调试信息："
        echo "- 当前用户: $(buf registry whoami)"
        echo "- 组织: buf.build/liuyuqiang"
        echo "- 镜像: ${DOCKER_IMAGE}"
        echo "- 插件: ${PLUGIN_NAME}"
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
