local M = {}

local default_config = {
  install_path = vim.fn.stdpath("data") .. "/union-lsp-formatter"
}

M.config = default_config

function M.set(config)
  setmetatable(config, { __index = default_config })
  M.config = config
end

function M.get()
  return M.config
end

function M.get_lang()
end

return M
