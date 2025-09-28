---@class ow.dap.hover.Node
---@field lang string
---@field item ow.dap.Item
---@field parent ow.dap.hover.Node?
---@field children ow.dap.hover.Node[]
---@field is_expanded boolean
---@field is_last_child boolean
local Node = {}
Node.__index = Node

---@param item ow.dap.Item
---@param parent ow.dap.hover.Node?
---@param lang string
---@return ow.dap.hover.Node
function Node.new(item, parent, lang)
    return setmetatable({
        lang = lang,
        item = item,
        parent = parent,
        children = {},
        is_expanded = false,
        is_last_child = false,
    }, Node)
end

---@return boolean
function Node:is_container()
    return self.item.variablesReference and self.item.variablesReference > 0
        or false
end

---@return boolean
function Node:is_c_lang()
    return self.lang == "c" or self.lang == "cpp"
end

---@return boolean
function Node:is_c_pointer()
    return self:is_c_lang()
        and self:is_container()
        and self.item.type:match(
                "%*%s*[const%s]*[volatile%s]*[restrict%s]*$"
            )
            ~= nil
end

---@return boolean
function Node:is_c_null_pointer()
    return self:is_c_pointer() and self.item.value:match("^0[xX]0*$") ~= nil
end

---@return string
function Node:get_tree_prefix()
    if not self.parent then
        return ""
    end

    local prefix = ""

    local node = self.parent
    while node and node.parent do
        if node.is_last_child then
            prefix = "   " .. prefix
        else
            prefix = "│  " .. prefix
        end
        node = node.parent
    end

    if self.is_last_child then
        prefix = prefix .. "└─ "
    else
        prefix = prefix .. "├─ "
    end

    return prefix
end

---@return boolean
function Node:is_c_array_element()
    return self:is_c_lang() and self.item.name:match("^%[?%d+%]?$") ~= nil
end

---@return string
function Node:format_c()
    if self:is_c_array_element() then
        return string.format(
            "%s = (%s) %s",
            self.item.name,
            self.item.type,
            self.item.value
        )
    end

    if self.item.value == "" then
        return string.format("%s %s", self.item.type, self.item.name)
    else
        return string.format(
            "%s %s = %s",
            self.item.type,
            self.item.name,
            self.item.value
        )
    end
end

---@return boolean
function Node:is_expandable()
    return self:is_container() and not self:is_c_null_pointer()
end

---@param content ow.dap.hover.Content
function Node:format_into(content)
    if self:is_expandable() then
        local marker = self.is_expanded and "-" or "+"
        content:add(marker .. " ", "@comment")
    else
        content:add("  ")
    end

    local tree_prefix = self:get_tree_prefix()
    if tree_prefix ~= "" then
        content:add(tree_prefix, "@comment")
    end

    local text
    if self:is_c_lang() then
        text = self:format_c()
    else
        error(string.format("Formatting for %s not implemented", self.lang))
    end

    content:add_with_treesitter(text, self.lang)
end

return Node
