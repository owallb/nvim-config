-- Tree node representation for DAP variables
local Content = require("ow.dap.hover.content")
local log = require("ow.log")

---@class ow.dap.hover.Node
---@field item ow.dap.Item The DAP item this node represents
---@field parent ow.dap.hover.Node? Parent node
---@field children ow.dap.hover.Node[] Child nodes
---@field is_expanded boolean Whether this node is expanded
---@field line_number integer Buffer line number where this node is displayed
---@field is_last_child boolean Whether this is the last child of its parent
local Node = {}
Node.__index = Node

---Create a new tree node
---@param item ow.dap.Item
---@param parent ow.dap.hover.Node?
---@return ow.dap.hover.Node
function Node.new(item, parent)
    return setmetatable({
        item = item,
        parent = parent,
        children = {},
        is_expanded = false,
        line_number = -1,
        is_last_child = false,
    }, Node)
end

---Check if this node represents a container (struct/array)
---@return boolean
function Node:is_container()
    return self.item.variablesReference and self.item.variablesReference > 0
        or false
end

---Get the tree prefix for this node (├─, └─, │, etc.)
---@return string
function Node:get_tree_prefix()
    if not self.parent then
        return "" -- Root node has no prefix
    end

    local prefix = ""

    -- Walk up the tree to build the prefix
    local node = self.parent
    while node and node.parent do
        if node.is_last_child then
            prefix = "   " .. prefix
        else
            prefix = "│  " .. prefix
        end
        node = node.parent
    end

    -- Add the final branch character
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
function Node:format_c_expression()
    if self:is_c_array_element() then
        return string.format(
            "%s = (%s) %s",
            self.item.name,
            self.item.type,
            self.item.value
        )
    end

    if self:is_c_pointer_child() then
        return string.format("*%s = %s", self.parent.item.name, self.item.value)
    end

    return string.format(
        "%s %s = %s",
        self.item.type,
        self.item.name,
        self.item.value
    )
end

---Format this node as highlighted content
---@param session dap.Session DAP session for making requests
---@return ow.dap.hover.Content
function Node:format(session)
    local content = Content.new()

    -- Add expansion marker for containers
    if self:is_container() then
        local marker = self.is_expanded and "-" or "+"
        content:add(marker .. " ", "@comment")
    else
        content:add("  ")
    end

    -- Add tree prefix
    local tree_prefix = self:get_tree_prefix()
    if tree_prefix ~= "" then
        content:add(tree_prefix, "@comment")
    end

    local stmt
    if session.filetype == "c" or session.filetype == "cpp" then
        stmt = self:format_c_expression()
    else
        error(
            string.format("Formatting for %s not implemented", session.filetype)
        )
    end
    content:add_with_treesitter(stmt, session.filetype)

    if self.item.value == "" then
        content:add("...", "@comment")
    end

    return content
end

return Node
