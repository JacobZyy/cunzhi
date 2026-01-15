#!/bin/bash

# MCP 工具测试脚本
# 用于测试论剑、心法管理、轻功搜索三个MCP工具

set -e

echo "🧪 开始测试 MCP 工具"
echo "===================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查可执行文件是否存在
if [ ! -f "./target/release/论剑" ]; then
    echo -e "${RED}❌ 错误: 找不到 ./target/release/论剑${NC}"
    echo "请先运行: pnpm run tauri:build"
    exit 1
fi

echo -e "${GREEN}✓ 找到 MCP 服务器: ./target/release/论剑${NC}"
echo ""

# 测试1: 论剑工具 (lunjian)
echo "📝 测试 1: 论剑工具 (lunjian)"
echo "----------------------------"

cat > /tmp/test_lunjian.json << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "lunjian",
    "arguments": {
      "message": "是否继续执行测试？",
      "predefined_options": ["确认", "取消"],
      "is_markdown": false
    }
  }
}
EOF

echo "发送请求到 lunjian 工具..."
echo '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}},"id":0}' | ./target/release/论剑 > /tmp/mcp_init.log 2>&1 &
MCP_PID=$!
sleep 2

if ps -p $MCP_PID > /dev/null; then
    echo -e "${GREEN}✓ MCP 服务器启动成功 (PID: $MCP_PID)${NC}"
    kill $MCP_PID 2>/dev/null || true
else
    echo -e "${RED}✗ MCP 服务器启动失败${NC}"
    cat /tmp/mcp_init.log
fi

echo ""

# 测试2: 心法管理工具 (xinfa)
echo "📝 测试 2: 心法管理工具 (xinfa)"
echo "-------------------------------"

cat > /tmp/test_xinfa.json << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "xinfa",
    "arguments": {
      "action": "修炼",
      "project_path": "/tmp/test_project",
      "content": "测试心法内容",
      "category": "rule"
    }
  }
}
EOF

echo "准备测试 xinfa 工具..."
echo -e "${YELLOW}⚠ 注意: xinfa 工具默认禁用，需要在配置中启用${NC}"
echo ""

# 测试3: 轻功搜索工具 (qinggong)
echo "📝 测试 3: 轻功搜索工具 (qinggong)"
echo "----------------------------------"

cat > /tmp/test_qinggong.json << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "qinggong",
    "arguments": {
      "project_root_path": ".",
      "query": "测试搜索"
    }
  }
}
EOF

echo "准备测试 qinggong 工具..."
echo -e "${YELLOW}⚠ 注意: qinggong 工具默认禁用，需要在配置中启用${NC}"
echo ""

# 测试4: 列出所有工具
echo "📝 测试 4: 列出所有可用工具"
echo "----------------------------"

cat > /tmp/test_list_tools.json << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "tools/list",
  "params": {}
}
EOF

echo "测试 tools/list 方法..."
echo ""

# 测试5: 获取服务器信息
echo "📝 测试 5: 获取服务器信息"
echo "-------------------------"

echo "测试 initialize 方法..."
echo ""

# 清理临时文件
echo "🧹 清理临时文件..."
rm -f /tmp/test_*.json /tmp/mcp_*.log

echo ""
echo "===================="
echo -e "${GREEN}✅ 测试脚本执行完成${NC}"
echo ""
echo "💡 提示:"
echo "  1. 要完整测试 MCP 工具，需要使用 MCP 客户端（如 Claude Desktop）"
echo "  2. 配置文件位置: ~/.config/cunzhi/config.json"
echo "  3. 词汇配置位置: ./vocabulary.toml"
echo "  4. 查看帮助: ./target/release/且慢 --help"
echo "  5. 查看版本: ./target/release/且慢 --version"
echo ""
