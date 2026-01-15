// 词汇配置模块
// 此模块包含从 vocabulary.toml 生成的所有核心词汇常量
// 由 build.rs 在编译时自动生成

// 引入生成的常量（已经是 pub const，无需再次导出）
include!(concat!(env!("OUT_DIR"), "/vocabulary_generated.rs"));
