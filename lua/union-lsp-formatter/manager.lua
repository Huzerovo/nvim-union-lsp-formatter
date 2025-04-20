local M

---@type table<LangDescriptor> | {}
M.lang = {}

---@param ldp LangDescriptor
function M.push(ldp)
    if ldp and ldp.name and ldp.name ~= "" then
        table.insert(M.lang, ldp)
    end
end

function M.list()
    for _, ldp in ipairs(M.lang) do
        print(ldp.name .. " use backend " .. ldp.backend)
    end
end

return M
