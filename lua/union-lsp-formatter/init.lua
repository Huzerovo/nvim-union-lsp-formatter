local M = {}

---@class UnionConfig
---@field auto_install ?boolean
---@field install_path ?string
---@field log_level ?number
---@field default_lsp_conf ?table
---@field formatter_conf ?table -- formatter configuration
---@field languages ?table<string, LangConfig> -- language configuration

---@class LangConfig
---@field name ?string -- a friendly name
---@field filetype ?string -- specify a filetype
---@field lsp ?string -- lsp backend name
---@field lsp_config ?table -- configuration for lspconfig.LANG.setup()
---@field fmt ?string -- formatter name, it can be the formatter.nvim default formatter for lang
---@field fmt_config ?table -- configuration for formatterm.filetype
---@field prettier_plugin ?string -- prettier plugin, if use "prettier" as formatter, you may need a prettier pluging

---@class LspUnionConfig
---@field filetype string
---@field backend string
---@field backend_conf ?table

---@class FmtUnionConfig
---@field filetype string
---@field backend string
---@field backend_conf ?table

---@class LangDescriptor
---@field name string
---@field backend string
---@field type "formatter.nvim" | "lspconfig" | nil

---@type UnionConfig
local default_config = {
  auto_install = false,
  install_path =
      vim.fn.stdpath("data") .. "/union-lsp-formatter/prettier-plugins",
  log_level =
      vim.log.levels.TRACE,
  default_lsp_conf = {
    capabilities = {
      textDocument = {
        semanticTokens = {
          multilineTokenSupport = true,
        }
      }
    },
    root_markers = { '.git' },
  },
  formatter_conf = {},
  languages = {},
}

---@type UnionConfig
M.config = default_config

---@type table<LspUnionConfig>
M.config_lsp = {}

---@type table<FmtUnionConfig>
M.config_fmt = {}

---Deep merge table src to table dst
---@param dst UnionConfig
---@param src UnionConfig
---@return UnionConfig
local function table_merge(dst, src)
  local l = dst
  local r = src
  assert(type(l) == "table", "dst should be a table but get " .. type(l))
  assert(type(r) == "table", "src should be a table but get " .. type(r))
  for k, v in pairs(r) do
    if l[k] == nil or type(l[k]) ~= "table" or type(v) ~= "table" then
      l[k] = v
    else
      table_merge(l[k], v)
    end
  end
  return dst
end

---Normalizing user configuration to LSP configuration and Formatter configuration
---@param config UnionConfig
local function normalized(config)
  M.config = table_merge(default_config, config)
  config = M.config

  ---@param ft string
  ---@param conf_language LangConfig
  for ft, conf_language in pairs(config.languages) do
    ft = conf_language.filetype or ft

    if conf_language.lsp and conf_language.lsp ~= "" then
      -- lspconfig as backend
      table.insert(M.config_lsp, {
        filetype = ft,
        backend = conf_language.lsp,
        backend_conf = conf_language.lsp_config or {}
      })
    elseif (conf_language.fmt and conf_language.fmt ~= "") 
      or conf_language.fmt_config then
      -- or (conf_language.fmt_config and not next(conf_language.fmt_config)) then --  什么鬼东西
      -- formatter.nvim as backend
      table.insert(M.config_fmt, {
        filetype = ft,
        backend = conf_language.fmt,
        backend_conf = conf_language.fmt_config or {}
      })
    end
  end -- for loop end

  return config
end

function filetype2lsp (config_lsp) 

end

---@param config UnionConfig
function M.setup(config)
  config = config or {}
  config = normalized(config)

  local manager = require('union-lsp-formatter.manager')

  -- Config for LSP
  ---@type table<LspUnionConfig>
  local config_lsp = M.config_lsp

  -- setup lspconfig
  vim.lsp.config('*', config.default_lsp_conf)

  ---@param v LspUnionConfig
  for _, v in pairs(config_lsp) do
    -- lspconfig[v.lsp].setup(v.conf)
    manager.push(v.filetype, {
      name = v.name,
      backend = v.lsp,
      type = "lspconfig",
    })
  end

  local formatter = require('formatter')
  if (formatter ~= nil) then
    ---@type table<FmtUnionConfig>
    local config_fmt = M.config_fmt

    if config_fmt and not next(config_fmt) then
      -- Ignore languages configurated in formatter_conf
      -- config.formatter_conf.filetype = config.formatter_conf.filetype or {}
      config.formatter_conf.filetype = {}
      local filetypes                = config.formatter_conf.filetype

      ---@param v FmtUnionConfig
      for _, v in pairs(config_fmt) do
        if not next(v.conf) then
          filetypes[v.filetype] = formatter[v.filetype][v.fmt]
        else
          filetypes[v.filetype] = v.conf
        end
        manager.push(v.filetype, {
          name = v.filetype,
          backend = v.fmt,
          type = "formatter.nvim",
        })
      end
      config.formatter_conf.filetype = filetypes
    end
    formatter.setup(config.formatter_conf)
  end

  require('union-lsp-formatter.autocmd')
end

return M

-- vim: ts=2 sts=2 sw=2
