local M = {}

---@class UnionConfigLsp
---@field filetype string
---@field lsp string
---@field conf table

---@class UnionConfigFmt
---@field filetype string
---@field fmt string
---@field conf table

---@type UnionConfig
local default_config = {
  auto_install = false,
  install_path = vim.fn.stdpath("data") .. "/union-lsp-formatter",
  default_lsp_conf = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  },
  formatter_conf = {},
  languages = {},
}

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
  ---@type UnionConfig
  M.config = table_merge(default_config, config)
  config = M.config

  ---@type table<UnionConfigLsp>
  M.config_lsp = {}
  ---@type table<UnionConfigFmt>
  M.config_fmt = {}

  ---@param lang_conf LangConfig
  for ft, lang_conf in pairs(config.languages) do
    if lang_conf.lsp and lang_conf.lsp ~= "" then
      lang_conf.lsp_config = lang_conf.lsp_config or {}

      -- if lsp_config is empty, use default_lsp_config
      if not next(lang_conf.lsp_config) then
        lang_conf.lsp_config = config.default_lsp_conf
      end

      table.insert(M.config_lsp, {
        filetype = ft,
        lsp = lang_conf.lsp,
        conf = lang_conf.lsp_config
      })
    elseif lang_conf.fmt and lang_conf.fmt ~= "" then
      lang_conf.fmt_config = lang_conf.fmt_config or {}

      -- if fmt_config is empty, use preconfigured formatter in formatter.nvim
      if not next(lang_conf.fmt_config) then
        local fmt_filetype = require('formatter.filetype')
        local fmt_default_formatter  = fmt_filetype[ft][lang_conf.fmt]
        lang_conf.fmt_config = {
            fmt_default_formatter
        }
      end

      table.insert(M.config_fmt, {
        filrtype = ft,
        fmt = lang_conf.fmt,
        conf = lang_conf.fmt_config
      })
    end
  end -- for loop end

  M.config = config
end

function M.get_config()
  return M.config
end

function M.get_config_lsp()
  return M.config_lsp
end

function M.get_config_fmt()
  return M.config_fmt
end

return M

-- vim: ts=2 sts=2 sw=2
