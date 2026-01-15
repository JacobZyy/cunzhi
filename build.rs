use serde::Deserialize;
use std::env;
use std::fs;
use std::path::Path;

#[derive(Debug, Deserialize)]
struct VocabularyConfig {
    app: AppVocabulary,
    executables: ExecutableVocabulary,
    mcp_tools: McpToolsVocabulary,
    actions: ActionsVocabulary,
}

#[derive(Debug, Deserialize)]
struct AppVocabulary {
    name_zh: String,
    name_en: String,
    description: String,
}

#[derive(Debug, Deserialize)]
struct ExecutableVocabulary {
    gui_name: String,
    mcp_server_name: String,
}

#[derive(Debug, Deserialize)]
struct McpToolsVocabulary {
    interaction: ToolConfig,
    memory: ToolConfig,
    search: ToolConfig,
}

#[derive(Debug, Deserialize)]
struct ToolConfig {
    id: String,
    name: String,
    description: String,
}

#[derive(Debug, Deserialize)]
struct ActionsVocabulary {
    memory_add: String,
    memory_recall: String,
}

fn main() {
    // Tauri 构建
    tauri_build::build();
    
    // 读取词汇配置文件
    let config_path = "vocabulary.toml";
    println!("cargo:rerun-if-changed={}", config_path);
    
    let config_content = fs::read_to_string(config_path)
        .expect("Failed to read vocabulary.toml. Please ensure the file exists in the project root.");
    
    let config: VocabularyConfig = toml::from_str(&config_content)
        .expect("Failed to parse vocabulary.toml. Please check the TOML syntax.");
    
    // 验证 Cargo.toml 中的可执行文件名是否一致
    check_cargo_toml_sync(&config);
    
    // 生成 Rust 代码
    let out_dir = env::var("OUT_DIR").unwrap();
    let dest_path = Path::new(&out_dir).join("vocabulary_generated.rs");
    
    let generated_code = generate_vocabulary_code(&config);
    fs::write(&dest_path, generated_code)
        .expect("Failed to write generated vocabulary code");
    
    println!("cargo:warning=Vocabulary configuration loaded successfully from vocabulary.toml");
}

fn check_cargo_toml_sync(config: &VocabularyConfig) {
    // 读取 Cargo.toml 检查可执行文件名
    if let Ok(cargo_content) = fs::read_to_string("Cargo.toml") {
        let gui_pattern = format!("name = \"{}\"", config.executables.gui_name);
        let mcp_pattern = format!("name = \"{}\"", config.executables.mcp_server_name);
        
        if !cargo_content.contains(&gui_pattern) {
            println!("cargo:warning=⚠️  GUI executable name in vocabulary.toml ('{}') does not match Cargo.toml. Please update [[bin]] name in Cargo.toml.", config.executables.gui_name);
        }
        
        if !cargo_content.contains(&mcp_pattern) {
            println!("cargo:warning=⚠️  MCP server executable name in vocabulary.toml ('{}') does not match Cargo.toml. Please update [[bin]] name in Cargo.toml.", config.executables.mcp_server_name);
        }
    }
}

fn generate_vocabulary_code(config: &VocabularyConfig) -> String {
    format!(
        r#"// 此文件由 build.rs 自动生成，请勿手动修改
// 配置来源: vocabulary.toml

// ============================================================================
// 应用程序名称
// ============================================================================

/// 应用程序名称（中文）
pub const APP_NAME_ZH: &str = "{}";

/// 应用程序名称（英文）
pub const APP_NAME_EN: &str = "{}";

/// 应用程序描述
pub const APP_DESCRIPTION: &str = "{}";

// ============================================================================
// 可执行文件名称
// ============================================================================

/// GUI 主程序可执行文件名
/// 注意：修改后需要同步更新 Cargo.toml 中的 [[bin]] name
pub const EXECUTABLE_GUI: &str = "{}";

/// MCP 服务器可执行文件名
/// 注意：修改后需要同步更新 Cargo.toml 中的 [[bin]] name
pub const EXECUTABLE_MCP_SERVER: &str = "{}";

// ============================================================================
// MCP 工具配置 - 交互工具
// ============================================================================

/// MCP 工具 ID - 交互工具（用于 MCP 协议）
pub const TOOL_ID_INTERACTION: &str = "{}";

/// MCP 工具名称 - 交互工具（显示给用户）
pub const TOOL_NAME_INTERACTION: &str = "{}";

/// MCP 工具描述 - 交互工具
pub const TOOL_DESC_INTERACTION: &str = "{}";

// ============================================================================
// MCP 工具配置 - 记忆管理
// ============================================================================

/// MCP 工具 ID - 记忆管理（用于 MCP 协议）
pub const TOOL_ID_MEMORY: &str = "{}";

/// MCP 工具名称 - 记忆管理（显示给用户）
pub const TOOL_NAME_MEMORY: &str = "{}";

/// MCP 工具描述 - 记忆管理
pub const TOOL_DESC_MEMORY: &str = "{}";

// ============================================================================
// MCP 工具配置 - 代码搜索
// ============================================================================

/// MCP 工具 ID - 代码搜索（用于 MCP 协议）
pub const TOOL_ID_SEARCH: &str = "{}";

/// MCP 工具名称 - 代码搜索（显示给用户）
pub const TOOL_NAME_SEARCH: &str = "{}";

/// MCP 工具描述 - 代码搜索
pub const TOOL_DESC_SEARCH: &str = "{}";

// ============================================================================
// 操作动词
// ============================================================================

/// 记忆管理操作 - 添加记忆
pub const ACTION_MEMORY_ADD: &str = "{}";

/// 记忆管理操作 - 回忆/检索记忆
pub const ACTION_MEMORY_RECALL: &str = "{}";

// ============================================================================
// 兼容性别名（保持与旧常量名称的兼容）
// ============================================================================

/// 应用名称别名（兼容旧代码）
pub const NAME: &str = APP_NAME_ZH;

/// 应用英文名称别名（兼容旧代码）
pub const NAME_EN: &str = APP_NAME_EN;

/// 工具 ID 别名 - zhi（兼容旧代码）
pub const TOOL_ZHI: &str = TOOL_ID_INTERACTION;

/// 工具 ID 别名 - ji（兼容旧代码）
pub const TOOL_JI: &str = TOOL_ID_MEMORY;

/// 工具 ID 别名 - sou（兼容旧代码）
pub const TOOL_SOU: &str = TOOL_ID_SEARCH;
"#,
        config.app.name_zh,
        config.app.name_en,
        config.app.description,
        config.executables.gui_name,
        config.executables.mcp_server_name,
        config.mcp_tools.interaction.id,
        config.mcp_tools.interaction.name,
        config.mcp_tools.interaction.description,
        config.mcp_tools.memory.id,
        config.mcp_tools.memory.name,
        config.mcp_tools.memory.description,
        config.mcp_tools.search.id,
        config.mcp_tools.search.name,
        config.mcp_tools.search.description,
        config.actions.memory_add,
        config.actions.memory_recall,
    )
}
