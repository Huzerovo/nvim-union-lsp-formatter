local M = {}

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
  config = require('union-lsp-formatter.config').config

  local manager = require('union-lsp-formatter.manager')

  ---@type table<UnionConfigLsp>
  local config_lsp = require('union-lsp-formatter.config').config_lsp

  ---@param v UnionConfigLsp
  for _, v in pairs(config_lsp) do
    lspconfig[v.lsp].setup(v.conf)
    manager.push(v.filetype, { name = v.name, backend = "lsp-config" })
  end

  ---@type table<UnionConfigFmt>
  local config_fmt = require('union-lsp-formatter.config').config_fmt

  if config_fmt and not next(config_fmt) then
    config.formatter_conf.filetype = config.formatter_conf.filetype or {}
    local filetypes = config.formatter_conf.filetypes

    ---@param v UnionConfigFmt
    for _, v in pairs(config_fmt) do
      if not next(v.conf) then
        filetypes[v.filetype] = formatter[v.filetype][v.fmt]
      else
        filetypes[v.filetype] = v.conf
      end
      manager.push(v.filetype ,{ name = v.filetype, backend = "formatter.nvim" })
    end
  end
  formatter.setup(config.formatter_conf)
  require('union-lsp-formatter.autocmd')

  require('union-lsp-formatter.utils').log_info("Union Lsp formatter loaded.")
end

return M

-- vim: ts=2 sts=2 sw=2
