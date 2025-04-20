# union-lsp-formatter

用一个统一的方式对格式化代码的插件进行配置。

## 配置

```lua
local config = {
    auto_install = false,
    formatter = {}, -- configuration for formatter, used in require('formatter').setup(config.formatter)
    lang_conf = {
        filetype = {
            lsp = "", -- lsp binary
            lsp_conf = {}, -- lsp config
            fmt_conf = {}, -- will be set to config.formatter.filetype
            prettier_plugin = "",
        },
        -- ...
    }
}
```
