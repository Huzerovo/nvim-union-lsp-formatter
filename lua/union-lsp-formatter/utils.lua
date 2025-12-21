---@module "utils"

local M = {}

local MAX_DEEP = 10
local INDENT_SPACE = "  "

-- Install a prettier plugin
---@param plugin string
function M.install(plugin)
  -- TODO impl
  error("No impl")
end

local function log(msg, level)
  local label = "UFM: "
  vim.notify(label .. msg, level)
end

---将src合并到dst，src值覆盖dst中的值
---@param dst UnionConfig
---@param src UnionConfig
---@return UnionConfig
function M.table_merge(dst, src)
  local l = dst
  local r = src
  assert(type(l) == "table", "dst should be a table but get " .. type(l))
  assert(type(r) == "table", "src should be a table but get " .. type(r))
  for k, v in pairs(r) do
    if l[k] == nil or type(l[k]) ~= "table" or type(v) ~= "table" then
      l[k] = v
    else
      M.table_merge(l[k], v)
    end
  end
  return dst
end

local function format_table_with_indent(t, indent, deep)
  if deep > MAX_DEEP then
    return indent .. "<...>\n"
  end
  local table_output = ""
  if (type(t) == "table") then
    for pos, val in pairs(t) do
      if (type(pos) == "number") then
        table_output = table_output .. format_table_with_indent(val, indent, deep + 1)
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

function M.log_debug(msg)
  log(msg, vim.log.levels.DEBUG)
end

function M.log_info(msg)
  log(msg, vim.log.levels.INFO)
end

function M.log_warn(msg)
  log(msg, vim.log.levels.WARN)
end

function M.log_error(msg)
  log(msg, vim.log.levels.ERROR)
end

return M

-- vim: ts=2 sts=2 sw=2
