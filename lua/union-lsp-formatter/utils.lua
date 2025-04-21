---@module "utils"

local M = {}

-- Install a prettier plugin
---@param plugin string
function M.install(plugin)
  -- TODO impl
  error("No impl")
end

local function log(msg, level)
  if require('union-lsp-formatter.config').config.log_level > level then
    return
  end
  vim.notify("UFM: " .. msg, level)
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
