# union-lsp-formatter

用一个统一的方式对格式化代码的插件进行配置。

## 配置

```lua
local config = {
  auto_install = false,
  install_path = "",
  default_lsp_conf = {}, -- 默认lspconfig配置，用于vim.lsp.config("*")
  formatter_conf = {}, -- formatter配置
  languages = {
    -- filetype
    c = {
      lsp = "clangd", -- 使用lspconfg clangd作为后端，
      fmt_conf = {}, -- 
      prettier_plugin = "", -- 使用formatter prettier作为后端，并使用插件
    },
        markdown = {
            fmt = "prettier"
        }
    -- ...
  }
}
-- Language configuration example:
--
-- local formatter = require('formatter')
-- {
--   {
--     name = "sh",
--     -- configuration for lspconfig
--     lsp = 'bashls',
--     -- Pass to require('lspconfig').bashls.setup()
--     lsp_config = {
--        capabilities = require('cmp_nvim_lsp').default_capabilities,
--     }
--
--     -- configuration for formatter.nvim
--     prettier_plugin = "prettier-plugin-sh",
--     formatter = '',
--     fmt_config = {
--       function()
--        return {
--          exe = 'prettier',
--          args = {
--            '--plugin',
--            'prettier-plugin-sh',
--            '--stdin-filepath',
--            formatter.util.escape_path(util.get_current_buffer_file_path()),
--          }
--        }
--       end
--     }
--   }
-- }
```
