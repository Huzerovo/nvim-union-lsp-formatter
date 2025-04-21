local M = {}


---@class LangDescriptor
---@field name string
---@field backend "formatter.nvim" | "lsp-config" | nil

---@type table<LangDescriptor> | {}
M.lang = {}

---@param ft string
---@param ldp LangDescriptor
function M.push(ft, ldp)
  if ldp and ldp.name and ldp.name ~= "" then
    M.lang[ft] = ldp
  end
end

function M.list()
  ---@param ft string
  ---@param ldp LangDescriptor
  for ft, ldp in pairs(M.lang) do
    print(ldp.name .. ":")
    print("  filetype: " .. ft)
    print("  backend: " .. ldp.backend)
  end
end

function M.show_config()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter.config").config)
end

function M.show_config_fmt()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter.config").config_fmt)
end

function M.show_config_lsp()
  local utils = require('union-lsp-formatter.utils')
  utils.tabledump(require("union-lsp-formatter.config").config_lsp)
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

  local backend = lang.backend

  if backend == "formatter.nvim" then
    formatter.format("", "", 1, vim.fn.line("$"))
    utils.log_info("Formatted with formatter.nvim")
  elseif backend == "lsp-config" then
    vim.lsp.buf.format()
    utils.log_info("Formatted with LSP")
  else
    utils.log_error("Unknow language server backend: " .. backend)
  end
end

return M

-- vim: ts=2 sts=2 sw=2
