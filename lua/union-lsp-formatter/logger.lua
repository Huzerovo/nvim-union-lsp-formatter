---@module "logger"

local M = {}
local TAG = "UFM"

local function log(msg, level)
  vim.notify(TAG .. ":" .. msg, level)
end

---log debug message
---@param msg string
function M.d(msg)
  log(msg, vim.log.levels.DEBUG)
end

---log info message
---@param msg string
function M.i(msg)
  log(msg, vim.log.levels.INFO)
end

---log warn message
---@param msg string
function M.w(msg)
  log(msg, vim.log.levels.WARN)
end

---log error message
---@param msg string
function M.e(msg)
  log(msg, vim.log.levels.ERROR)
end

return M
