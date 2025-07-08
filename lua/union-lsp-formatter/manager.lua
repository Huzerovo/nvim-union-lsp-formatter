---@module 'manager'

local M = {}

---@type table<string, table<LangDescriptor>|LangDescriptor> | {}
M.lang = {}

---@param ft string
---@param ldp LangDescriptor
function M.push(ft, ldp)
  assert(type(ft) == "string", "ft must be a string")
  if ldp and ldp.name and ldp.name ~= "" then
    if M.lang[ft] ~= nil then
      M.lang[ft] = table.insert(M.lang[ft], ldp)
    else
      M.lang[ft] = ldp
    end
  end
end

---A prettier output
---@param ft string
---@param ldp LangDescriptor
---@return string
local function format_with_indent(ft, ldp)
  local ret = "[ " .. ldp.name .. " ]\n"
  ret = ret .. "- filetype: " .. ft .. "\n"
  ret = ret .. "-  backend: " .. ldp.backend .. "\n"
  ret = ret .. "-     type: " .. ldp.type .. "\n"
  return ret
end

function M.list()
  ---@param ft string
  ---@param ldp LangDescriptor
  for ft, ldp in pairs(M.lang) do
    print(format_with_indent(ft, ldp))
  end
end

function M.show_config()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter").config)
end

function M.show_config_fmt()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter").config_fmt)
end

function M.show_config_lsp()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter").config_lsp)
end

function M.format()
  local formatter = require('formatter.format')
  local utils = require('union-lsp-formatter.utils')
  local ft = vim.bo.filetype

  local lang = M.lang[ft]
  if lang == nil then
    utils.log_warn("No language server backend for filetype: " .. ft)
    return
  end

  local type = lang.type

  if type == "formatter.nvim" then
    formatter.format("", "", 1, vim.fn.line("$"))
    utils.log_info("Formatted with formatter.nvim")
  elseif type == "lsp-config" then
    vim.lsp.buf.format()
    utils.log_info("Formatted with LSP")
  else
    utils.log_error("Unknow fotmatter backend: " .. type)
  end
end

return M

-- vim: ts=2 sts=2 sw=2
