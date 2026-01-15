# 寸止项目核心词汇配置指南

## 📋 概述

本项目的核心词汇（应用名称、可执行文件名、MCP 工具 ID 等）已经配置化，可以通过修改 `vocabulary.toml` 文件来自定义这些词汇，无需修改源代码。

## 🎯 配置文件位置

```
vocabulary.toml  # 项目根目录
```

## 📝 配置文件结构

### 1. 应用程序信息

```toml
[app]
name_zh = "寸止"           # 应用程序中文名称
name_en = "cunzhi"         # 应用程序英文名称
description = "智能代码审查工具"  # 应用程序描述
```

### 2. 可执行文件名称

```toml
[executables]
gui_name = "等一下"         # GUI 主程序可执行文件名
mcp_server_name = "寸止"    # MCP 服务器可执行文件名
```

**⚠️ 重要提示**：修改可执行文件名后，需要同步更新 `Cargo.toml` 中的 `[[bin]]` 配置：

```toml
[[bin]]
name = "等一下"  # 与 vocabulary.toml 中的 gui_name 保持一致
path = "src/rust/main.rs"

[[bin]]
name = "寸止"    # 与 vocabulary.toml 中的 mcp_server_name 保持一致
path = "src/rust/bin/mcp_server.rs"
```

### 3. MCP 工具配置

#### 交互工具 (zhi)

```toml
[mcp_tools.interaction]
id = "zhi"                  # MCP 协议中的工具 ID
name = "寸止"               # 显示给用户的工具名称
description = "智能代码审查交互工具..."  # 工具描述
```

#### 记忆管理工具 (ji)

```toml
[mcp_tools.memory]
id = "ji"                   # MCP 协议中的工具 ID
name = "记忆"               # 显示给用户的工具名称
description = "项目记忆管理工具..."  # 工具描述
```

#### 代码搜索工具 (sou)

```toml
[mcp_tools.search]
id = "sou"                  # MCP 协议中的工具 ID
name = "搜"                 # 显示给用户的工具名称
description = "代码语义搜索工具..."  # 工具描述
```

### 4. 操作动词

```toml
[actions]
memory_add = "记忆"         # 添加记忆的操作名称
memory_recall = "回忆"      # 检索记忆的操作名称
```

## 🔧 如何自定义词汇

### 步骤 1：修改配置文件

编辑 `vocabulary.toml`，修改你想要自定义的词汇。

**示例**：将应用名称改为"代码助手"

```toml
[app]
name_zh = "代码助手"
name_en = "code-helper"
description = "智能代码审查工具"
```

### 步骤 2：同步 Cargo.toml（如果修改了可执行文件名）

如果你修改了 `executables.gui_name` 或 `executables.mcp_server_name`，需要手动更新 `Cargo.toml`：

```toml
[[bin]]
name = "你的新GUI名称"
path = "src/rust/main.rs"

[[bin]]
name = "你的新MCP服务器名称"
path = "src/rust/bin/mcp_server.rs"
```

### 步骤 3：重新编译

```bash
# 清理旧的构建产物
cargo clean

# 重新构建项目
pnpm run tauri:build
```

### 步骤 4：验证

```bash
# 检查可执行文件是否生成
ls -lh target/release/ | grep "你的新名称"

# 测试帮助信息
./target/release/你的新GUI名称 --help
./target/release/你的新GUI名称 --version
```

## 🏗️ 技术实现

### 构建时代码生成

项目使用 `build.rs` 在编译时读取 `vocabulary.toml` 并生成 Rust 常量：

```rust
// 生成的代码位于 target/debug/build/cunzhi-xxx/out/vocabulary_generated.rs
pub const APP_NAME_ZH: &str = "寸止";
pub const APP_NAME_EN: &str = "cunzhi";
pub const EXECUTABLE_GUI: &str = "等一下";
// ... 更多常量
```

### 代码引用

所有需要使用核心词汇的地方都通过 `vocabulary` 模块引用：

```rust
use crate::constants::vocabulary;

// 使用常量
let app_name = vocabulary::APP_NAME_ZH;
let gui_cmd = vocabulary::EXECUTABLE_GUI;
```

### 构建时验证

`build.rs` 会在编译时检查 `vocabulary.toml` 与 `Cargo.toml` 的一致性：

```
warning: ⚠️  GUI executable name in vocabulary.toml ('等一下') does not match Cargo.toml. 
Please update [[bin]] name in Cargo.toml.
```

## 📊 配置化的好处

1. **集中管理**：所有核心词汇在一个文件中管理
2. **类型安全**：编译时生成常量，保持 Rust 的类型安全
3. **零运行时开销**：生成的是 `const` 常量，无运行时性能损失
4. **易于定制**：修改配置文件即可，无需修改源代码
5. **构建时验证**：自动检查配置一致性

## ⚠️ 注意事项

### 1. 可执行文件名同步

修改 `vocabulary.toml` 中的可执行文件名后，**必须**同步更新 `Cargo.toml`，否则会导致：
- 编译生成的文件名与配置不一致
- MCP 服务器无法找到 GUI 程序
- 构建时会收到警告提示

### 2. MCP 工具 ID 兼容性

修改 MCP 工具 ID（如 `zhi`、`ji`、`sou`）会影响：
- AI 助手的工具调用（需要更新 Claude Desktop 配置）
- 现有的 MCP 客户端集成
- 用户的使用习惯

建议保持工具 ID 稳定，只修改显示名称。

### 3. 重新编译

修改 `vocabulary.toml` 后**必须**重新编译才能生效：

```bash
cargo clean  # 清理旧的生成文件
pnpm run tauri:build  # 重新构建
```

### 4. 字符编码

确保 `vocabulary.toml` 使用 UTF-8 编码，以正确处理中文字符。

## 🔍 故障排除

### 问题 1：编译失败，提示找不到常量

**原因**：`vocabulary.toml` 格式错误或缺失

**解决**：
1. 检查 `vocabulary.toml` 语法是否正确
2. 确保所有必需字段都已填写
3. 运行 `cargo clean` 清理缓存

### 问题 2：可执行文件名不匹配

**原因**：`vocabulary.toml` 与 `Cargo.toml` 不一致

**解决**：
1. 检查构建警告信息
2. 同步更新 `Cargo.toml` 中的 `[[bin]]` name
3. 重新编译

### 问题 3：MCP 服务器找不到 GUI 程序

**原因**：可执行文件名配置错误

**解决**：
1. 确认 `vocabulary.toml` 中的 `gui_name` 正确
2. 确认两个可执行文件在同一目录
3. 检查文件权限（需要可执行权限）

## 📚 相关文档

- [核心词汇调用链路分析](./CORE_VOCABULARY_ANALYSIS.md)
- [MCP 工具详细说明](./ACEMCP.md)
- [项目 README](./README.md)

## 🎉 示例：完整的自定义流程

假设你想将项目改名为"智能助手"：

1. **修改 vocabulary.toml**：
```toml
[app]
name_zh = "智能助手"
name_en = "smart-helper"

[executables]
gui_name = "助手"
mcp_server_name = "智能助手"
```

2. **修改 Cargo.toml**：
```toml
[[bin]]
name = "助手"
path = "src/rust/main.rs"

[[bin]]
name = "智能助手"
path = "src/rust/bin/mcp_server.rs"
```

3. **重新构建**：
```bash
cargo clean
pnpm run tauri:build
```

4. **验证结果**：
```bash
./target/release/助手 --help
# 输出：智能助手 - 智能代码审查工具
```

---

**最后更新**: 2026-01-15  
**版本**: v0.4.0
