local M = {}

---@class UnionConfig
---@field auto_install ?boolean
---@field install_path ?string
---@field log_level ?number
---@field default_lsp_conf ?table
---@field formatter_conf ?table -- formatter configuration
---@field languages ?table<string, LangConfig> -- language configuration

---@class LangConfig
---@field lsp ?string -- lsp backend name
---@field fmt ?string -- formatter name, it can be the formatter.nvim default formatter for lang
---@field fmt_spec ?function -- See :help formatter-config-spec
---@field prettier_plugin ?string -- prettier plugin, if use "prettier" as formatter, you may need a prettier pluging

---@class LspConfig
---@field default_lsp_conf ?table
---@field backend ?table<string>

---@class FormatterFiletypeConfig
---@field filetype ?string
---@field fmt ?string
---@field fmt_spec ?function

---@class LangDescriptor
---@field name string
---@field backend string
---@field type "formatter.nvim" | "lspconfig" | nil


--初始化为默认配置
---@type UnionConfig
M.config = {}

--存储lspconfig配置
---@type LspConfig
M.config_lsp = {}

--存储formatter配置
---@type table<FormatterFiletypeConfig>
M.config_fmt_ft = {}

---将user_config转化为config_lsp以及config_fmt
---@param default_config UnionConfig
---@param user_config UnionConfig | {}
local function normalized(default_config, user_config)
  local utils = require('union-lsp-formatter.utils')
  ---@type UnionConfig
  local cfg = utils.table_merge(default_config, user_config)

  ---@type LspConfig
  local cfg_lsp = {
    default_lsp_conf = cfg.default_lsp_conf or {},
    backend = {}
  }

  ---@type table<FormatterFiletypeConfig>
  local cfg_fmt_ft = {}

  ---@param ft string
  ---@param conf_lang LangConfig
  for ft, conf_lang in pairs(cfg.languages) do
    if conf_lang then
      if conf_lang.lsp then
        -- lspconfig as backend
        table.insert(cfg_lsp.backend, conf_lang.lsp)
      elseif conf_lang.fmt then
        table.insert(cfg_fmt_ft, {
          filetype = ft,
          fmt = conf_lang.fmt,
          fmt_spec = conf_lang.fmt_config or {}
        })
      else
        utils.log_warn("language "..ft.." configurated without lspconfig and formatter.")
      end
      ---@TODO install pretter plugin
    end
  end -- for loop end

  return cfg,cfg_lsp,cfg_fmt_ft
end

---@param config_lsp LspConfig
local function setup_lspconfig(config_lsp)
  -- setup lspconfig
  vim.lsp.config('*', config_lsp.default_lsp_conf)

  for _, lsp in pairs(config_lsp.backend) do
    vim.lsp.enable(lsp)
  end

  -- for _, v in pairs(config_lsp) do
  --   manager.push(v.filetype, {
  --     name = v.name,
  --     backend = v.lsp,
  --     type = "lspconfig",
  --   })
  -- end

end

---@param config_fmt table
---@param config_fmt_ft table<FormatterFiletypeConfig>
local function setup_formatter(config_fmt, config_fmt_ft)
  local formatter = require('formatter')
  if (formatter == nil) then
    return
  end

  if config_fmt_ft == nil or config_fmt_ft == {} then
    return
  end

  local formatter_filetype = {}

  ---@param ffc FormatterFiletypeConfig
  for _, ffc in pairs(config_fmt_ft) do
    if ffc.filetype then
      formatter_filetype[ffc.filetype] = {ffc.fmt , ffc.fmt_spec }
    end
  end

  config_fmt.filetype = formatter_filetype

  formatter.setup(config_fmt)

  -- ---@param v FormatterConfig
  -- for _, v in pairs(config_fmt) do
  --   if not next(v.conf) then
  --     filetypes[v.filetype] = formatter[v.filetype][v.fmt]
  --   else
  --     filetypes[v.filetype] = v.conf
  --   end
  --   -- manager.push(v.filetype, {
  --   --   name = v.filetype,
  --   --   backend = v.fmt,
  --   --   type = "formatter.nvim",
  --   -- })
  -- end
  -- config.formatter_conf.filetype = filetypes
  -- formatter.setup(config.formatter_conf)
end

---@param user_config UnionConfig
function M.setup(user_config)
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

  ---@type LangConfig
  languages = {},
}


  M.config , M.config_lsp , M.config_fmt_ft = normalized(default_config, user_config or {})

  setup_lspconfig(M.config_lsp)

  setup_formatter(M.config.formatter_conf, M.config_fmt_ft)

  local manager = require('union-lsp-formatter.manager')

  require('union-lsp-formatter.autocmd')
end

return M

-- vim: ts=2 sts=2 sw=2
