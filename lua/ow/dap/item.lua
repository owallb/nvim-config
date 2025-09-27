---@class ow.dap.Item
---@field name string
---@field type string
---@field value string
---@field variablesReference? number
local Item = {}
Item.__index = Item

---@param name string
---@param type string
---@param value string
---@param variablesReference? number
---@return ow.dap.Item
function Item.new(name, type, value, variablesReference)
    return setmetatable({
        name = name,
        type = type,
        value = value,
        variablesReference = variablesReference,
    }, Item)
end

---@param var dap.Variable
---@return ow.dap.Item
function Item.from_var(var)
    return Item.new(
        var.name,
        var.type,
        var.value,
        var.variablesReference
    )
end

return Item
