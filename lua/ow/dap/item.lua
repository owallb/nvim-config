---@class ow.dap.Item
---@field name string
---@field type string
---@field value string
---@field variablesReference? number
---@field depth integer
local Item = {}
Item.__index = Item

---@param name string
---@param type string
---@param value string
---@param variablesReference? number
---@param depth integer
---@return ow.dap.Item
function Item.new(name, type, value, variablesReference, depth)
    return setmetatable({
        name = name,
        type = type,
        value = value,
        variablesReference = variablesReference,
        depth = depth,
    }, Item)
end

---@param var dap.Variable
---@param depth integer
---@return ow.dap.Item
function Item.from_var(var, depth)
    return Item.new(
        var.name,
        var.type,
        var.value,
        var.variablesReference,
        depth
    )
end

return Item
