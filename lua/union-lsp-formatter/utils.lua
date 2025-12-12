---@module "utils"

local M = {}

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

function M.tabledump(tb)
  local function sub_print_r(t, indent)
    if (type(t) == "table") then
      for pos, val in pairs(t) do
        if (type(val) == "table") then
          if (type(pos) == 'number') then
            print(indent .. "{")
          else
            print(indent .. pos .. " = {")
          end
          sub_print_r(val, indent .. "  ")
          print(indent .. "},")
        elseif (type(val) == "string") then
          print(indent .. pos .. ' = "' .. val .. '"')
        else
          print(indent .. pos .. " = " .. tostring(val))
        end
      end
    else
      print(indent .. tostring(t))
    end
  end
  if (type(tb) == "table") then
    print("{")
    sub_print_r(tb, "  ")
    print("}")
  else
    sub_print_r(tb, "  ")
  end
  print()
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
