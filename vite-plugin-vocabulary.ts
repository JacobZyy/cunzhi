import type { Plugin } from 'vite'
import fs from 'node:fs'
import path from 'node:path'
import { dirname } from 'node:path'
import { fileURLToPath, URL } from 'node:url'
import { parse } from 'smol-toml'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export function vocabularyPlugin(): Plugin {
  return {
    name: 'vocabulary-plugin',
    enforce: 'pre',

    resolveId(id) {
      if (id === 'virtual:vocabulary') {
        return '\0virtual:vocabulary'
      }
    },

    load(id) {
      if (id === '\0virtual:vocabulary') {
        // 读取 vocabulary.toml
        const vocabularyPath = path.resolve(process.cwd(), 'vocabulary.toml')
        const tomlContent = fs.readFileSync(vocabularyPath, 'utf-8')
        const config = parse(tomlContent)

        // 生成 JavaScript 代码（不使用 TypeScript 语法）
        const code = `
// 此文件由 vite-plugin-vocabulary 自动生成，请勿手动修改
// 源文件: vocabulary.toml

export const vocabulary = ${JSON.stringify(config, null, 2)};

// 便捷访问
export const appName = ${JSON.stringify(config.app.name_zh)};
export const appNameEn = ${JSON.stringify(config.app.name_en)};
export const appDescription = ${JSON.stringify(config.app.description)};
export const guiName = ${JSON.stringify(config.executables.gui_name)};
export const mcpServerName = ${JSON.stringify(config.executables.mcp_server_name)};

export const toolInteraction = ${JSON.stringify(config.mcp_tools.interaction)};
export const toolMemory = ${JSON.stringify(config.mcp_tools.memory)};
export const toolSearch = ${JSON.stringify(config.mcp_tools.search)};

export const memoryAddAction = ${JSON.stringify(config.actions.memory_add)};
export const memoryRecallAction = ${JSON.stringify(config.actions.memory_recall)};
`
        return code
      }
    },
  }
}
