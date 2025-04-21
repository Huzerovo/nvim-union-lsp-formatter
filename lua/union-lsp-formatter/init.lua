local M = {}

---@class LangConfig
---@field name ?string -- language name
---@field lsp ?string -- lsp name
---@field lsp_config ?table -- configuration for lspconfig.LANG.setup()
---@field fmt ?string -- formatter name, it can be the formatter.nvim default formatter for lang
---@field fmt_config ?table -- configuration for formatterm.filetype
---@field prettier_plugin ?string -- prettier plugin, if use "prettier" as formatter, you may need a prettier pluging

---@class UnionConfig
---@field auto_install ?boolean
---@field install_path ?string
---@field default_lsp_conf ?table
---@field formatter_conf ?table -- formatter configuration
---@field languages ?table<LangConfig> -- language configuration


---@class LangDescriptor
---@field name string
---@field backend "formatter.nvim" | "lsp-config" | nil

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

---@param config UnionConfig
function M.setup(config)
  local lspconfig = require('lspconfig')
  local formatter = require('formatter')
  -- setup lspconfig
  if (lspconfig == nil) then
    error("lspconfig is required")
    return nil
  end

  if (formatter == nil) then
    error("formatter is required")
    return nil
  end

  config = config or {}

  require("union-lsp-formatter.config").normalized(config)
  config = require('union-lsp-formatter.config').get_config()

  ---@type table<UnionConfigLsp>
  local config_lsp = require('union-lsp-formatter.config').get_config_lsp()

  ---@param v UnionConfigLsp
  for _, v in pairs(config_lsp) do
    lspconfig[v.lsp].setup(v.conf)
  end

  ---@type table<UnionConfigFmt>
  local config_fmt = require('union-lsp-formatter.config').get_config_fmt()

  config.formatter_conf.filetype = config.formatter_conf.filetype or {}
  local filetype = config.formatter_conf.filetype

  ---@param v UnionConfigFmt
  for _, v in pairs(config_fmt) do
    filetype[v.filetype] = v.conf
  end
  formatter.setup(config.formatter_conf)

end

function M.format()
  local lspconfig = require('lspconfig')
  local formatter = require('formatter.format')
  if (vim.o.formatexpr == nil or vim.o.formatexpr == "") then
    formatter.format("", "", 1, vim.fn.line("$"))
    vim.notify("Formatted with formatter.nvim")
  else
    if (lspconfig ~= nil) then
      vim.lsp.buf.format()
      vim.notify("Formatted with LSP")
    end
  end
end

-- list configured lang
function M.list()
end

return M

-- vim: ts=2 sts=2 sw=2
