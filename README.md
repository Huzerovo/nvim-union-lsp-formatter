# union-lsp-formatter

用一个统一的方式对格式化代码的插件进行配置。

## 配置

```lua
local config = {
    auto_install = false,
    install_path = "",
    default_lsp_conf = {},
    formatter_conf = {}, -- configuration for formatter, used in require('formatter').setup(config.formatter)
    languages = {
        example_ft = {
            name = "", -- a friendly name

            lsp = "", -- lsp binary, if it is defined, use lspconfig as formatter
            -- deprecated
            lsp_conf = {}, -- lsp config

            fmt_conf = {}, -- will be set to config.formatter.filetype[example_ft]
                           -- if it is defined, use formatter.nvim as formatter
            prettier_plugin = "", -- if use prettier in formatter.nvim, you may need a prettier plugin
        },
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
