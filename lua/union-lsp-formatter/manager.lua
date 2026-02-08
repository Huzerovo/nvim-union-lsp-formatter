---@module 'manager'

local M = {}

local MAX_DEEP = 10
local INDENT_SPACE = "  "

local logger = require('union-lsp-formatter.logger')
local utils = require('union-lsp-formatter.utils')

---@class LangDescriptor
---@field backend string | table | nil
---@field type "formatter.nvim" | "lspconfig" | nil

---@class Lang
---@field ldp LangDescriptor
---@field format_callback function | nil

---@type table<string,Lang>
M.lang = {}

M.installed_plugins = {}

---格式化表格为字符串，带缩进
---@param t table
---@param indent string
---@param deep number
---@return string
local function format_table_with_indent(t, indent, deep)
  if deep > MAX_DEEP then
    return indent .. "<...>\n"
  end
  local table_output = ""
  if (type(t) == "table") then
    for pos, val in pairs(t) do
      if (type(pos) == "number") then
        if (type(val) == "table") then
          table_output = table_output .. indent .. "{\n"
          table_output = table_output .. format_table_with_indent(val, indent .. INDENT_SPACE, deep + 1)
          table_output = table_output .. indent .. "},\n"
        else
          table_output = table_output .. indent .. tostring(val) .. ",\n"
        end
      else
        if (type(val) == "table") then
          table_output = table_output .. indent .. pos .. " = {\n"
          table_output = table_output .. format_table_with_indent(val, indent .. INDENT_SPACE, deep + 1)
          table_output = table_output .. indent .. "},\n"
        else
          table_output = table_output .. indent .. pos .. " = " .. tostring(val) .. ",\n"
        end
      end
      -- if (type(val) == "table") then
      --   if (type(pos) == 'number') then
      --     table_output = table_output .. indent .. "{\n"
      --   else
      --     table_output = table_output .. indent .. pos .. " = {\n"
      --   end
      --   table_output = table_output .. format_table_with_indent(val, indent .. "  ", deep + 1)
      --   table_output = table_output .. indent .. "},"
      -- else
      --   table_output = table_output .. indent .. pos .. " = " .. tostring(val)
      -- end
    end
  else
    table_output = table_output .. indent .. tostring(t) .. ",\n"
  end

  return table_output
end

---将table格式化为字符串
---@param tb table
---@return string
function table_to_string(tb)
  assert(tb ~= nil, "table_to_string: input is nil")

  assert(type(tb) == "table", "table_to_string: input should be table but get " .. type(tb))

  return "{\n" .. format_table_with_indent(tb, INDENT_SPACE .. INDENT_SPACE, 0) .. INDENT_SPACE .. "}"
end

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
  local ret = "(" .. ldp.type .. ") " .. ft .. " => "
  if type(ldp.backend) == "table" then
    ret = ret .. "<fmt_spec> " .. table_to_string(ldp.backend) .. "\n"
  elseif type(ldp.backend) == "function" then
    ret = ret .. "<fmt_spec> custom function\n"
  else
    ret = ret .. ldp.backend .. "\n"
  end
  return ret
end

function M.list()
  local lsp_group = ""
  local fmt_group = ""
  local Unknow_group = ""
  ---@param ft string
  ---@param l LangDescriptor
  for ft, l in pairs(M.lang) do
    if (not l) or (not l.ldp) or (l.ldp == {}) then
      print("Missing configuration for [ " .. ft .. " ]\n")
    else
      if l.ldp.type == "lspconfig" then
        lsp_group = lsp_group .. format_with_indent(ft, l.ldp)
      elseif l.ldp.type == "formatter.nvim" then
        fmt_group = fmt_group .. format_with_indent(ft, l.ldp)
      else
        Unknow_group = Unknow_group .. "Unknow backend for [ " .. ft .. " ]"
      end
    end
  end
  print(lsp_group)
  print(fmt_group)
  if (Unknow_group ~= "") then
    print(Unknow_group)
  end
end

function M.show_config()
  print(table_to_string(require("union-lsp-formatter").config))
end

function M.show_config_fmt()
  print(table_to_string(require("union-lsp-formatter").config_fmt_ft))
end

function M.show_config_lsp()
  print(table_to_string(require("union-lsp-formatter").config_lsp))
end

---获取prettier可执行文件路径
---@return string|nil
function M.get_prettier_exe()
  if utils.is_command_exist("prettier") then
    return "prettier"
  elseif utils.is_command_exist("npx") and utils.is_npm_package_installed('prettier') then
    return "npx --prettier " .. M.get_install_path() .. " prettier"
  end
  return nil
end

---判断是否是合法的prettier插件
---@param pkg string
---@return boolean
local function is_prettier_plugin(pkg)
  if pkg == nil or pkg == "" then
    return false
  end

  local prefix = "prettier-plugin-"
  if vim.startswith(pkg, prefix) then
    return true
  end

  return false
end

---安装prettier或prettier插件
---@param pkg string
---@return boolean
function M.install(pkg)
  if pkg == nil or pkg == "" then
    return false
  end

  if pkg == "prettier" then
    if utils.is_command_exist('prettier') then
      return true
    end
    return utils.install_npm_package(pkg)
  end

  return M.install_prettier_plugin(pkg)
end

---移除prettier或prettier插件
---@param pkg string
---@return boolean
function M.remove(pkg)
  if pkg == nil or pkg == "" then
    return false
  end

  if pkg == "prettier" then
    return utils.remove_npm_package(pkg)
  end

  if not is_prettier_plugin(pkg) then
    logger.e(pkg .. " is not a valid prettier plugin")
    return false
  end

  return utils.remove_npm_package(pkg)
end

---格式化
function M.format()
  local ft = vim.bo.filetype

  local lang = M.lang[ft]
  if lang.format_callback == nil then
    logger.w("No language server backend for filetype: " .. ft)
    return
  end
  lang.format_callback()
end

-- ---检查prettier是否安装
-- ---@return boolean
-- function M.is_prettier_installed()
--   if utils.is_command_exist("prettier") then
--     return true
--   end

--   if utils.is_npm_package_installed("prettier") then
--     return true
--   end
--   return false
-- end

-- ---检查prettier插件是否安装
-- ---@param plugin string
-- ---@return boolean
-- function M.is_prettier_plugin_installed(plugin)
--   if (plugin == nil) or (type(plugin) ~= "string") or (plugin == "") then
--     return false
--   end

--   return utils.is_npm_package_installed(plugin)
-- end

-- ---安装prettier
-- ---@return boolean
-- function M.knstall_prettier()
--   logger.i("Installing prettier...")
--   return utils.install_npm_package("prettier")
-- end

-- ---安装prettier插件
-- ---@param plugin string
-- ---@return boolean
-- function M.install_prettier_plugin(plugin)
--   if not is_prettier_plugin(plugin) then
--     logger.e(plugin .. " is not a valid prettier plugin")
--     return false
--   end

--   logger.i("Installing plugin: " .. plugin)
--   return utils.install_npm_package(plugin)
-- end

return M

-- vim: ts=2 sts=2 sw=2
