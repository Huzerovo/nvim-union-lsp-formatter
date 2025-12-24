---@module "utils"

local M = {}

local MAX_DEEP = 10
local INDENT_SPACE = "  "

-- Install a prettier plugin
---@param plugin string
function M.install_prettier_plugin(plugin)
  local logger = require('union-lsp-formatter.logger')
  logger.i("Installing plugin: " .. plugin)
  local install_path = M.get_install_path()
  local cmd = "npm install --prefix " .. install_path .. " " .. plugin
  logger.d("Running command: " .. cmd)
  local result = os.execute(cmd)
  if result == 0 then
    logger.i("Successfully installed plugin: " .. plugin)
  else
    logger.e("Failed to install plugin: " .. plugin)
  end
end

---@return string
function M.get_install_path()
  if require('union-lsp-formatter').config.install_path ~= nil then
    return require('union-lsp-formatter').config.install_path
  end
  return vim.fn.stdpath('data') .. "/union-lsp-formatter/prettier-plugins"
end

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

function M.table_to_string(tb)
  assert(tb ~= nil, "table_to_string: input is nil")
  assert(type(tb) == "table", "table_to_string: input should be table but get " .. type(tb))

  return "{\n" .. format_table_with_indent(tb, INDENT_SPACE .. INDENT_SPACE, 0) .. INDENT_SPACE .. "}"
end

return M

-- vim: ts=2 sts=2 sw=2
