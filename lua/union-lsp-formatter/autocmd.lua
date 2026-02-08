---This is the parameters for {command}.
---See `:help nvim_create_user_command()`
---@class cb_opts
---@field name string
---@field args string
---@field fargs table
---@field nargs string
---I think other parameters will not be used in here...

---@class commands
---@field cb fun(opts: cb_opts):nil
---@field nargs number
---@field desc string

local UFM_CMD = "UFM"
local UFM_GROUP = "UFMCommands"

---@type table<string, commands>
local manager = require('union-lsp-formatter.manager')
local cmd_list = {
  list = {
    cb = manager.list,
    desc = "List configurated filetype."

  },
  fmt = {
    cb = manager.show_config_fmt,
    desc = "Show formatter.format configuration."
  },
  lsp = {
    cb = manager.show_config_lsp,
    desc = "show lspconfig configuration."
  },
  config = {
    cb = manager.show_config,
    desc = "Show plugin configuration."
  }
}

local cmd_callback = function(opts)
  local cmd = opts.args
  if not cmd_list[cmd] then
    return false
  end

  cmd_list[cmd].cb()
end

local commands_list = function()
  local ret = {}
  for i in pairs(cmd_list) do
    table.insert(ret, i)
  end
  return ret
end

vim.api.nvim_create_user_command(
  UFM_CMD,
  cmd_callback,
  {
    bang = false,
    nargs = 1,
    desc = "Union Formatter Manager commands",
    complete = commands_list,
  }
)


-- vim: ts=2 sts=2 sw=2
