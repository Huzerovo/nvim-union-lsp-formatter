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

---@type table<string, commands>
local cmd_list = {
  UFM = {
    ---@param opts cb_opts
    cb = function(opts)
      if opts.args == 'list' then
        require('union-lsp-formatter.manager').list()
      elseif opts.args == 'fmt' then
        require('union-lsp-formatter.manager').show_config_fmt()
      elseif opts.args == 'lsp' then
        require('union-lsp-formatter.manager').show_config_lsp()
      elseif opts.args == 'conf' then
        require('union-lsp-formatter.manager').show_config()
      end
    end,
    nargs = 1,
    desc = "Show configurations"
  }
}

vim.api.nvim_create_augroup("UFMCommands", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = "UFMCommands",
  desc = "Create Union Formatter Manager commands",
  callback = function()
    for k, v in pairs(cmd_list) do
      vim.api.nvim_create_user_command(k, v.cb, {
        nargs = v.nargs,
        desc = v.desc
      })
    end
  end,
})


-- vim: ts=2 sts=2 sw=2
