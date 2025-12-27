---@module "utils"

local M = {}

local MAX_DEEP = 10
local INDENT_SPACE = "  "

local logger = require('union-lsp-formatter.logger')

---检查命令是否存在
---@param cmd string
---@return boolean
local function is_command_exist(cmd)
  local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
  if handle == nil then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

---安装npm包
---@param pkg string
---@param install_path string
---@return boolean
local function install_npm_package(pkg, install_path)
  logger.i("Installing npm package: " .. pkg .. " to " .. install_path)
  local cmd = "npm install --prefix " .. install_path .. " " .. pkg
  logger.d("Running command: " .. cmd)
  local result = os.execute(cmd)
  if result == 0 then
    logger.i("Successfully installed npm package: " .. pkg)
    return true
  else
    logger.e("Failed to install npm package: " .. pkg)
    return false
  end
end

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

---检查prettier是否安装
---@return boolean
function M.is_prettier_installed()
  if is_command_exist("prettier") then
    return true
  end
  local install_path = M.get_install_path()
  local prettier_path = install_path .. "/node_modules/.bin/prettier"
  local file = io.open(prettier_path, "r")
  if file ~= nil then
    io.close(file)
    return true
  else
    return false
  end
end

---检查prettier插件是否安装
---@param plugin string
---@return boolean
function M.is_prettier_plugin_installed(plugin)
  local install_path = M.get_install_path()
  local plugin_name = plugin:gsub("^.+/(.+)$", "%1") -- extract package name from full package path
  local plugin_path = install_path .. "/node_modules/" .. plugin_name
  local file = io.open(plugin_path, "r")
  if file ~= nil then
    io.close(file)
    return true
  else
    return false
  end
end

---安装prettier
function M.install_prettier()
  logger.i("Installing prettier...")
  local install_path = M.get_install_path()
  install_npm_package("prettier", install_path)
end

---安装prettier插件
---@param plugin string
function M.install_prettier_plugin(plugin)
  logger.i("Installing plugin: " .. plugin)
  local install_path = M.get_install_path()
  install_npm_package(plugin, install_path)
end

---获取prettier可执行文件路径
---@return string|nil
function M.get_prettier_exe()
  if is_command_exist("prettier") then
    return "prettier"
  elseif is_command_exist("npx") then
    return "npx --prettier " .. M.get_install_path() .. " prettier"
  end
  return nil
end

---获取npm包安装路径
---@return string
function M.get_install_path()
  if require('union-lsp-formatter').config.install_path ~= nil then
    return require('union-lsp-formatter').config.install_path
  end
  return vim.fn.stdpath('data') .. "/union-lsp-formatter/prettier-plugins"
end

---将table格式化为字符串
---@param tb table
---@return string
function M.table_to_string(tb)
  assert(tb ~= nil, "table_to_string: input is nil")
  assert(type(tb) == "table", "table_to_string: input should be table but get " .. type(tb))

  return "{\n" .. format_table_with_indent(tb, INDENT_SPACE .. INDENT_SPACE, 0) .. INDENT_SPACE .. "}"
end

return M

-- vim: ts=2 sts=2 sw=2
