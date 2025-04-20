local M = {}

---@class LangConfig
---@field filetype ?string -- language name
---@field lsp ?string -- lsp name
---@field lsp_config ?table -- configuration for lspconfig.LANG.setup()
---@field formatter ?string -- formatter name
---@field ft_config ?table<function> -- configuration for formatter filetype
---@field prettier_plugin ?string -- prettier plugin

---@class Config
---@field formatter_conf ?table -- formatter configuration
---@field lang_conf ?table<LangConfig> -- language configuration


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

---@param config Config
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

  ---@type table<LangConfig>
  config.lang_conf = config.lang_conf or {}

  config.formatter_conf    = config.formatter_conf or {}
  config.formatter_conf.filetype = config.formatter_conf.filetype or {}

  ---@type table
  local lsp_config_mt = {
    __index = {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }
  }

  for _, lang in pairs(config.lang_conf) do
    -- init lspconfig for lang
    if (lang.lsp ~= nil) then
      lang.lsp_config = lang.lsp_config or {}
      setmetatable(lang.lsp_config, lsp_config_mt)
      lspconfig[lang.lsp].setup(lang.lsp_config)
    end
    if (lang.name ~= nil) then
      config.formatter_conf.filetype[lang.name] = lang.ft_config
    end
    --TODO: install prettier plugin
  end

  formatter.setup(config.formatter_conf)
  require('union-lsp-formatter.config').set(config)
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

return M
