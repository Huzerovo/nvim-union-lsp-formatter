# union-lsp-formatter

用一个统一的方式对格式化代码的插件进行配置。

## 配置

```lua
local config = {
    auto_install = false,
    default_lsp_conf = {},
    default_fmt_conf = {},
    formatter_conf = {}, -- configuration for formatter, used in require('formatter').setup(config.formatter)
    lang_conf = {
        example_ft = {
            name = "", -- a friendly name
            lsp = "", -- lsp binary, if it is defined, use lspconfig as formatter
            lsp_conf = {}, -- lsp config

            fmt_conf = {}, -- will be set to config.formatter.filetype[example_ft]
                           -- if it is defined, use formatter.nvim as formatter
            prettier_plugin = "", -- if use prettier in formatter.nvim, you may need a prettier plugin
        },
        -- ...
    }
}
```
