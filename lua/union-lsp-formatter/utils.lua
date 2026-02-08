---@module "utils"

local M = {}

local logger = require('union-lsp-formatter.logger')

---获取npm包安装路径
---@return string
function M.get_install_path()
  local conf_path = require('union-lsp-formatter').config.install_path
  local default_path = vim.fn.stdpath('data') .. "/union-lsp-formatter/prettier-plugins"
  if conf_path ~= nil then
    local cmd = "test -d '" .. default_path "'"
    local suc, _, code = os.execute(cmd)
    if suc == true and code == 0 then
      return conf_path
    end
    logger.w("Configurated path: " .. conf_path .. " is not a valid path."
      .. "use default_path: " .. default_path)
  end
  return default_path
end

---检查命令是否存在
---@param cmd string
---@return boolean
function M.is_command_exist(cmd)
  local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
  if handle == nil then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

---检查npm包是否已安装
---@param pkg string
---@return boolean
function M.is_npm_package_installed(pkg)
  if not M.is_command_exist('npm') then
    logger.e("npm is not installed")
    return false
  end

  if type(pkg) ~= 'string' or pkg == '' then
    return false
  end

  local install_path = M.get_install_path()
  local package_path = install_path .. "/node_modules/" .. pkg
  local cmd = "test -d '" .. package_path .. "'"
  local status, _, code = os.execute(cmd)
  return status == true and code == 0
end

---安装npm包
---@param pkg string
---@return boolean
function M.install_npm_package(pkg)
  if M.is_npm_package_installed(pkg) then
    return true
  end

  local install_path = M.get_install_path()

  logger.i("Installing npm package: " .. pkg .. " to " .. install_path)
  local cmd = "npm install --prefix " .. install_path .. " " .. pkg
  logger.d("Running command: " .. cmd)
  local status, _, code = os.execute(cmd)
  if status == true and code == 0 then
    logger.i("Successfully installed npm package: " .. pkg)
    return true
  else
    logger.e("Failed to install npm package: " .. pkg)
    return false
  end
end

---移除npm包
---@param pkg string
---@return boolean
function M.remove_npm_package(pkg)
  if not M.is_npm_package_installed(pkg) then
    return true
  end

  local install_path = M.get_install_path()
  local cmd = "npm remove --prefix " .. install_path .. " " .. pkg
  local status, _, code = os.execute(cmd)
  if status == true and code == 0 then
    return true
  end

  return false
end

return M

-- vim: ts=2 sts=2 sw=2
