---@class ow.dap.hover.Node
---@field item ow.dap.Item
---@field parent ow.dap.hover.Node?
---@field children ow.dap.hover.Node[]
---@field is_expanded boolean
---@field is_last_child boolean
local Node = {}
Node.__index = Node

---@param item ow.dap.Item
---@param parent ow.dap.hover.Node?
---@return ow.dap.hover.Node
function Node.new(item, parent)
    local node = setmetatable({
        item = item,
        parent = parent,
        children = {},
        is_expanded = false,
        is_last_child = false,
    }, Node)

    return node
end

---@return boolean
function Node:is_container()
    return self.item.variablesReference and self.item.variablesReference > 0
        or false
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
    return self.item.name:match("^%[?%d+%]?$") ~= nil
end

---@return boolean
function Node:is_c_pointer_child()
    return self.parent
            and self.parent.item.type:match(
                "%*%s*[const%s]*[volatile%s]*[restrict%s]*$"
            ) ~= nil
        or false
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

    if self:is_c_pointer_child() then
        return string.format("%s = %s", self.item.name, self.item.value)
    end

    return string.format(
        "%s %s = %s",
        self.item.type,
        self.item.name,
        self.item.value
    )
end

---@param session dap.Session
---@param content ow.dap.hover.Content
function Node:format_into(session, content)
    if self:is_container() then
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
    if session.filetype == "c" or session.filetype == "cpp" then
        text = self:format_c()
    else
        error(
            string.format("Formatting for %s not implemented", session.filetype)
        )
    end

    content:add_with_treesitter(text, session.filetype)

    if self.item.value == "" then
        content:add("...", "@comment")
    end
end

return Node
