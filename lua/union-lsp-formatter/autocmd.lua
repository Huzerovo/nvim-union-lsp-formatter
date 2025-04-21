local cmd = vim.api.nvim_create_user_command


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
            elseif opts.args == "config" then
                require('union-lsp-formatter.manager').show_config()
            elseif opts.args == "fmt" then
                require('union-lsp-formatter.manager').show_config_fmt()
            elseif opts.args == "lsp" then
                require('union-lsp-formatter.manager').show_config_lsp()
            end
        end,
        nargs = 1,
        desc = "Show configured formatteres"
    }
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    desc = "Create Union formatter Manager commands",
    callback = function()
        for k, v in pairs(cmd_list) do
            cmd(k, v.cb, { nargs = v.nargs, desc = v.desc })
        end
    end
})
