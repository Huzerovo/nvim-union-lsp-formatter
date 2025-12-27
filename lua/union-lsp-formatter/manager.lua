---@module 'manager'

local M = {}

local logger = require('union-lsp-formatter.logger')
local utils = require('union-lsp-formatter.utils')

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
  if ldp.type == "formatter.nvim" then
    local formatter = require('formatter.format')
    M.lang[ft].format_callback = function()
      logger.d("Formatting with formatter.nvim for filetype: " .. ft)
      if not formatter.format("", "", 1, vim.fn.line("$")) then
        logger.w("Failed to format with formatter.nvim for filetype: " .. ft)
      end
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
    ret = ret .. "<fmt_spec> " .. utils.table_to_string(ldp.backend) .. "\n"
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
  print(utils.table_to_string(require("union-lsp-formatter").config))
end

function M.show_config_fmt()
  print(utils.table_to_string(require("union-lsp-formatter").config_fmt_ft))
end

function M.show_config_lsp()
  print(utils.table_to_string(require("union-lsp-formatter").config_lsp))
end

function M.install(package)
  if package == "prettier" then
    if utils.is_prettier_installed() then
      return
    end
    utils.install_prettier()
    return
  end

  if utils.is_prettier_plugin_installed(package) then
    return
  end
  utils.install_prettier_plugin(package)
  M.installed_plugins[package] = true
end

function M.format()
  local ft = vim.bo.filetype

  local lang = M.lang[ft]
  if lang.format_callback == nil then
    logger.w("No language server backend for filetype: " .. ft)
    return
  end
  lang.format_callback()
end

return M

-- vim: ts=2 sts=2 sw=2
