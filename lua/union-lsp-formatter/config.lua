local M = {}

---@class LangConfig
---@field name ?string -- a friendly name
---@field filetype ?string -- specify a filetype
---@field lsp ?string -- lsp backend name
---@field lsp_config ?table -- configuration for lspconfig.LANG.setup()
---@field fmt ?string -- formatter name, it can be the formatter.nvim default formatter for lang
---@field fmt_config ?table -- configuration for formatterm.filetype
---@field prettier_plugin ?string -- prettier plugin, if use "prettier" as formatter, you may need a prettier pluging

---@class UnionConfig
---@field auto_install ?boolean
---@field install_path ?string
---@field log_level ?number
---@field default_lsp_conf ?table
---@field formatter_conf ?table -- formatter configuration
---@field languages ?table<string, LangConfig> -- language configuration

---@class UnionConfigLsp
---@field name string
---@field filetype string
---@field lsp string
---@field conf table

---@class UnionConfigFmt
---@field name string
---@field filetype string
---@field fmt string
---@field conf table

---@type UnionConfig
local default_config = {
  auto_install = false,
  install_path = vim.fn.stdpath("data") .. "/union-lsp-formatter",
  log_level = vim.log.levels.TRACE,
  default_lsp_conf = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  },
  formatter_conf = {},
  languages = {},
}

---@type UnionConfig
M.config = default_config

---@type table<UnionConfigLsp>
M.config_lsp = {}

---@type table<UnionConfigFmt>
M.config_fmt = {}

---Deep merge user config and default config
---@param dst UnionConfig
---@param src UnionConfig
---@return UnionConfig
local function table_merge(dst, src)
  local merge_task = {}
  merge_task[dst] = src

  ---@type UnionConfig | nil
  local l = dst

  while l do
    assert(type(l) == "table", "dst should be a table but get " .. type(l))

    local r = merge_task[l]
    for k, v in pairs(r) do
      if l[k] == nil or type(l[k]) ~= "table" or type(v) ~= "table" then
        l[k] = v
      else
        merge_task[l[k]] = v
      end
    end

    merge_task[l] = nil
    l, r = next(merge_task, l)
  end
  return dst
end

---@param config UnionConfig
function M.normalized(config)
  M.config = table_merge(default_config, config)
  config = M.config

  ---@type UnionConfigLsp | {}
  local clsp = {}

  ---@type UnionConfigFmt | {}
  local cfmt = {}

  ---@param ft string
  ---@param lang_conf LangConfig
  for ft, lang_conf in pairs(config.languages) do
    ft = lang_conf.filetype or ft

    -- this language is configurated with lsp-config backend
    if lang_conf.lsp and lang_conf.lsp ~= "" then
      lang_conf.lsp_config = lang_conf.lsp_config or {}

      -- if lsp_config is empty, use default_lsp_config
      if not next(lang_conf.lsp_config) then
        lang_conf.lsp_config = config.default_lsp_conf
      end

      clsp = {
        name = lang_conf.name or ft,
        filetype = ft,
        lsp = lang_conf.lsp,
        conf = lang_conf.lsp_config
      }
      table.insert(M.config_lsp, clsp)
    -- this language is configurated with formatter.nvim as backend
    elseif (lang_conf.fmt and lang_conf.fmt ~= "")
        or (lang_conf.fmt_config and not next(lang_conf.fmt_config)
        ) then
      lang_conf.fmt_config = lang_conf.fmt_config or {}

      cfmt = {
        name = lang_conf.name or ft,
        filetype = ft,
        fmt = lang_conf.fmt,
        conf = lang_conf.fmt_config
      }
      table.insert(M.config_fmt, cfmt)
    else
      vim.notify("Unconfigurated filetype: ".. ft)
    end
  end -- for loop end

  M.config["_normalized"] = true
end

return M

-- vim: ts=2 sts=2 sw=2
