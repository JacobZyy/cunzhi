#!/bin/bash

# 测试工具名称配置化
# 验证 MCP 工具是否正确使用了 vocabulary.toml 中的配置

set -e

echo "🧪 测试工具名称配置化"
echo "======================"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查可执行文件
if [ ! -f "./target/release/论剑" ]; then
    echo "❌ 找不到 ./target/release/论剑"
    exit 1
fi

echo -e "${GREEN}✓ 找到 MCP 服务器: ./target/release/论剑${NC}"
echo ""

# 创建临时文件
TEMP_OUT="/tmp/mcp_test_$$.json"

# 测试 tools/list
echo -e "${BLUE}📤 测试 tools/list - 列出所有工具${NC}"
echo ""

(
    echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
    sleep 0.5
    echo '{"jsonrpc":"2.0","method":"notifications/initialized"}'
    sleep 0.5
    echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
    sleep 1
) | ./target/release/论剑 2>/dev/null | grep -A 100 '"method":"tools/list"' > "$TEMP_OUT" || true

echo "📥 MCP 服务器返回的工具列表："
echo ""

# 解析并显示工具信息
if [ -f "$TEMP_OUT" ] && [ -s "$TEMP_OUT" ]; then
    # 提取工具名称
    echo "工具 ID 列表："
    grep -o '"name":"[^"]*"' "$TEMP_OUT" | cut -d'"' -f4 | while read -r tool_name; do
        echo "  - $tool_name"
    done
    echo ""
    
    # 检查是否包含配置的工具名称
    if grep -q '"name":"lunjian"' "$TEMP_OUT"; then
        echo -e "${GREEN}✓ 找到论剑工具 (lunjian)${NC}"
    else
        echo -e "${YELLOW}⚠ 未找到论剑工具 (lunjian)${NC}"
    fi
    
    if grep -q '"name":"xinfa"' "$TEMP_OUT"; then
        echo -e "${GREEN}✓ 找到心法管理工具 (xinfa)${NC}"
    else
        echo -e "${YELLOW}⚠ 未找到心法管理工具 (xinfa) - 可能被禁用${NC}"
    fi
    
    if grep -q '"name":"qinggong"' "$TEMP_OUT"; then
        echo -e "${GREEN}✓ 找到轻功搜索工具 (qinggong)${NC}"
    else
        echo -e "${YELLOW}⚠ 未找到轻功搜索工具 (qinggong) - 可能被禁用${NC}"
    fi
    
    echo ""
    echo "完整响应内容："
    cat "$TEMP_OUT" | jq '.' 2>/dev/null || cat "$TEMP_OUT"
else
    echo "⚠ 未获取到工具列表响应"
fi

# 清理
rm -f "$TEMP_OUT"

echo ""
echo "======================"
echo -e "${GREEN}✅ 测试完成${NC}"
echo ""
echo "💡 配置文件位置:"
echo "  - vocabulary.toml (核心词汇配置)"
echo "  - ~/.config/cunzhi/config.json (运行时配置)"
echo ""
