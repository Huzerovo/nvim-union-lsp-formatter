local M = {}

---@class LangConfig @field name ?string -- a friendly name @field filetype
---?string -- specify a filetype @field lsp ?string -- lsp backend name @field
---lsp_config ?table -- configuration for lspconfig.LANG.setup() @field fmt
---?string -- formatter name, it can be the formatter.nvim default formatter
---for lang @field fmt_config ?table -- configuration for formatterm.filetype
---@field prettier_plugin ?string -- prettier plugin, if use "prettier" as
---formatter, you may need a prettier pluging

---@class UnionConfig @field auto_install ?boolean @field install_path ?string
---@field log_level ?number @field default_lsp_conf ?table @field
---formatter_conf ?table -- formatter configuration @field languages
---?table<string, LangConfig> -- language configuration

---@class UnionConfigLsp @field name string @field filetype string @field lsp
---string @field conf table

---@class UnionConfigFmt @field name string @field filetype string @field fmt
---string @field conf table

---@type UnionConfig
M.config = default_config

---@type table<UnionConfigLsp>
M.config_lsp = {}

---@type table<UnionConfigFmt>
M.config_fmt = {}

---@type UnionConfig
local default_config = {
  auto_install = false,
  install_path =
      vim.fn.stdpath("data") .. "/union-lsp-formatter",
  log_level =
      vim.log.levels.TRACE,
  default_lsp_conf = {
    capabilities =
        require('cmp_nvim_lsp').default_capabilities(),
  },
  formatter_conf = {},
  languages = {},
}

---Deep merge user config and default config @param dst UnionConfig @param src
---UnionConfig @return UnionConfig
---@bug bug somttime merge failed, and return the default_config in fact
-- local function table_merge(dst, src)
--   local merge_task = {}
--   merge_task[dst] = src

--   ---@type UnionConfig | nil
--   local l = dst

--   ---@bug this does not work correctly
--   while l do
--     print("merging...")
--     assert(type(l) == "table", "dst should be a table but get " .. type(l))

--     local r = merge_task[l]
--     for k, v in pairs(r) do
--       if l[k] == nil or type(l[k]) ~= "table" or type(v) ~= "table" then
--         l[k] = v
--       else
--         merge_task[l[k]] = v
--       end
--     end

--     merge_task[l] = nil
--     l, r = next(merge_task, l)
--   end
--   return dst
-- end

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

---@param config UnionConfig
local function normalized(config)
  M.config = table_merge(default_config, config)
  config = M.config

  print("UFM: normalized")
  ---@type UnionConfigLsp | {}
  local clsp = {}

  ---@type UnionConfigFmt | {}
  local cfmt = {}

  ---@param ft string @param lang_conf LangConfig
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
    elseif (lang_conf.fmt and lang_conf.fmt ~= "") or (lang_conf.fmt_config and
          not next(lang_conf.fmt_config)) then
      lang_conf.fmt_config = lang_conf.fmt_config or {}

      cfmt = {
        name = lang_conf.name or ft,
        filetype = ft,
        fmt = lang_conf.fmt,
        conf = lang_conf.fmt_config
      }
      table.insert(M.config_fmt, cfmt)
    else
      vim.notify("Unconfigurated filetype: " .. ft)
    end
  end -- for loop end

  M.config["_normalized"] = true
  return config
end

---@param config UnionConfig
function M.setup(config)
  if (config == nil) then
    return nil
  end
  -- lazy loading command group
  local lazy_group = vim.api.nvim_create_augroup("UnionLspGroup", {
    clear = true
  })

  config = config or {}

  -- require("union-lsp-formatter.config").normalized(config) config =
  -- require('union-lsp-formatter.config').config
  local status, ok = pcall(normalized, config)
  if not status then print("UFM: failed to normalized config.") end

  local manager = require('union-lsp-formatter.manager')

  -- Config for LSP
  ---@type table<UnionConfigLsp>
  local config_lsp = M.config_lsp

  -- setup lspconfig
  local lspconfig = require('lspconfig')
  if (lspconfig ~= nil) then
    ---@param v UnionConfigLsp
    for _, v in pairs(config_lsp) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = v.filetype,
        group = lazy_group,
        callback = function()
          vim.notify("callback function for " .. v.filetype)
        end
      })
      lspconfig[v.lsp].setup(v.conf)
      manager.push(v.filetype, { name = v.name, backend = "lsp-config" })
    end
  end

  local formatter = require('formatter')
  if (formatter ~= nil) then
    ---@type table<UnionConfigFmt>
    local config_fmt = M.config_fmt

    if config_fmt and not next(config_fmt) then
      config.formatter_conf.filetype = config.formatter_conf.filetype or {}
      local filetypes                = config.formatter_conf.filetypes

      ---@param v UnionConfigFmt
      for _, v in pairs(config_fmt) do
        if not next(v.conf) then
          filetypes[v.filetype] = formatter[v.filetype][v.fmt]
        else
          filetypes[v.filetype] = v.conf
        end
        manager.push(v.filetype, {
          name = v.filetype,
          backend = "formatter.nvim"
        })
      end
    end
    ---@todo add lazy loading for it
    formatter.setup(config.formatter_conf)
  end

  require('union-lsp-formatter.autocmd')

  require('union-lsp-formatter.utils').log_info("Union Lsp formatter loaded.")
end

return M

-- vim: ts=2 sts=2 sw=2
