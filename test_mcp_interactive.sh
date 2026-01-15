#!/bin/bash

# MCP 工具交互式测试脚本
# 通过标准输入输出与 MCP 服务器交互

set -e

echo "🧪 MCP 工具交互式测试"
echo "====================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查可执行文件
if [ ! -f "./target/release/论剑" ]; then
    echo -e "${RED}❌ 找不到 ./target/release/论剑${NC}"
    echo "请先运行: pnpm run tauri:build"
    exit 1
fi

echo -e "${GREEN}✓ 找到 MCP 服务器: ./target/release/论剑${NC}"
echo ""

# 创建命名管道
FIFO_IN="/tmp/mcp_in_$$"
FIFO_OUT="/tmp/mcp_out_$$"
mkfifo "$FIFO_IN" "$FIFO_OUT"

# 清理函数
cleanup() {
    echo ""
    echo "🧹 清理资源..."
    rm -f "$FIFO_IN" "$FIFO_OUT"
    kill $MCP_PID 2>/dev/null || true
}
trap cleanup EXIT

# 启动 MCP 服务器
echo "🚀 启动 MCP 服务器..."
./target/release/论剑 < "$FIFO_IN" > "$FIFO_OUT" 2>&1 &
MCP_PID=$!
sleep 1

if ! ps -p $MCP_PID > /dev/null; then
    echo -e "${RED}❌ MCP 服务器启动失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ MCP 服务器已启动 (PID: $MCP_PID)${NC}"
echo ""

# 发送初始化请求
echo -e "${BLUE}📤 发送 initialize 请求...${NC}"
cat > "$FIFO_IN" << 'EOF'
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"clientInfo":{"name":"test-client","version":"1.0.0"}}}
EOF

sleep 2
echo -e "${BLUE}📥 响应:${NC}"
timeout 2 cat "$FIFO_OUT" || echo "超时或无响应"
echo ""

# 发送 initialized 通知
echo -e "${BLUE}📤 发送 initialized 通知...${NC}"
cat > "$FIFO_IN" << 'EOF'
{"jsonrpc":"2.0","method":"notifications/initialized"}
EOF

sleep 1
echo ""

# 列出工具
echo -e "${BLUE}📤 发送 tools/list 请求...${NC}"
cat > "$FIFO_IN" << 'EOF'
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
EOF

sleep 2
echo -e "${BLUE}📥 响应:${NC}"
timeout 2 cat "$FIFO_OUT" || echo "超时或无响应"
echo ""

# 测试论剑工具
echo -e "${BLUE}📤 测试 lunjian 工具...${NC}"
echo -e "${YELLOW}⚠ 注意: 这将弹出 GUI 窗口，需要手动操作${NC}"
read -p "按 Enter 继续..."

cat > "$FIFO_IN" << 'EOF'
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"lunjian","arguments":{"message":"测试论剑工具\n\n这是一个测试消息","predefined_options":["确认","取消","跳过"],"is_markdown":true}}}
EOF

echo "等待用户操作 GUI..."
sleep 5
echo -e "${BLUE}📥 响应:${NC}"
timeout 5 cat "$FIFO_OUT" || echo "超时或无响应"
echo ""

echo -e "${GREEN}✅ 交互式测试完成${NC}"
echo ""
echo "💡 提示:"
echo "  - 如果没有看到响应，可能是因为 MCP 协议需要完整的握手流程"
echo "  - 建议使用 Claude Desktop 或其他 MCP 客户端进行完整测试"
echo "  - 查看日志: ~/.local/share/cunzhi/logs/"
