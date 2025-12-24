---@module 'manager'

local M = {}

---@class Lang
---@field ldp LangDescriptor
---@field format_callback function | nil

---@type table<string,Lang>
M.lang = {}

M.installed_plugins = {}

---@param ft string
---@param ldp LangDescriptor
function M.push(ft, ldp)
  assert(type(ft) == "string", "ft must be a string")
  M.lang[ft] = {
    ldp = ldp,
    format_callback = nil
  }
  -- if M.lang[ft] ~= nil then
  --   M.lang[ft].ldp = table.insert(M.lang[ft].ldp, ldp)
  -- else
  --   M.lang[ft].ldp = ldp
  -- end
  local logger = require('union-lsp-formatter.logger')
  if ldp.type == "formatter.nvim" then
    local formatter = require('formatter.format')
    M.lang[ft].format_callback = function()
      logger.d("Formatting with formatter.nvim for filetype: " .. ft)
      formatter.format("", "", 1, vim.fn.line("$"))
    end
  elseif ldp.type == "lspconfig" then
    M.lang[ft].format_callback = function()
      logger.d("Formatting with LSP for filetype: " .. ft)
      vim.lsp.buf.format()
    end
  else
    M.lang[ft].format_callback = nil
  end
end

---A prettier output
---@param ft string
---@param ldp LangDescriptor
---@return string
local function format_with_indent(ft, ldp)
  local ret = ft .. ":"
  ret = ret .. " (" .. ldp.type .. ") "
  if type(ldp.backend) == "table" then
    ret = ret .. "<fmt_spec> " .. require("union-lsp-formatter.utils").table_to_string(ldp.backend) .. "\n"
  else
    ret = ret .. ldp.backend .. "\n"
  end
  return ret
end

function M.list()
  ---@param ft string
  ---@param l LangDescriptor
  for ft, l in pairs(M.lang) do
    if (not l) or (not l.ldp) or (l.ldp == {}) then
      print("Missing configuration for [ " .. ft .. " ]\n")
    else
      print(format_with_indent(ft, l.ldp))
    end
  end
end

function M.show_config()
  local utils = require('union-lsp-formatter.utils')
  print(utils.table_to_string(require("union-lsp-formatter").config))
end

function M.show_config_fmt()
  local utils = require('union-lsp-formatter.utils')
  print(utils.table_to_string(require("union-lsp-formatter").config_fmt_ft))
end

function M.show_config_lsp()
  local utils = require('union-lsp-formatter.utils')
  print(utils.table_to_string(require("union-lsp-formatter").config_lsp))
end

function M.install(plugin)
  local utils = require('union-lsp-formatter.utils')
  utils.install_prettier_plugin(plugin)
  M.installed_plugins[plugin] = true
end

function M.format()
  -- local formatter = require('formatter.format')
  local logger = require('union-lsp-formatter.logger')
  local ft = vim.bo.filetype

  local lang = M.lang[ft]
  if lang.format_callback == nil then
    logger.w("No language server backend for filetype: " .. ft)
    return
  end
  lang.format_callback()

  -- local type = lang.ldp.type

  -- if type == "formatter.nvim" then
  --   formatter.format("", "", 1, vim.fn.line("$"))
  --   logger.i("Formatted with formatter.nvim")
  -- elseif type == "lspconfig" then
  --   vim.lsp.buf.format()
  --   logger.i("Formatted with LSP")
  -- else
  --   logger.e("Unknow fotmatter backend: " .. type)
  -- end
end

return M

-- vim: ts=2 sts=2 sw=2
