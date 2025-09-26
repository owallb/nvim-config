local Content = require("ow.dap.hover.content")
local Node = require("ow.dap.hover.node")

---@class ow.dap.hover.Tree
---@field session dap.Session
---@field root ow.dap.hover.Node?
local Tree = {}
Tree.__index = Tree

---@param session dap.Session
---@return ow.dap.hover.Tree
function Tree.new(session)
    return setmetatable({
        session = session,
        root_node = nil,
        line_to_node = {},
        extmark_to_node = {},
    }, Tree)
end

---@async
---@param item ow.dap.Item
function Tree:build(item)
    self.root = Node.new(item, nil)

    if self.root:is_container() then
        self:load_children(self.root)
        self.root.is_expanded = true
    end
end

---@async
---@param node ow.dap.hover.Node
---@return boolean success
function Tree:load_children(node)
    if not node:is_container() or #node.children > 0 then
        return true -- Already loaded or not a container
    end

    local err, resp = self.session:request("variables", {
        variablesReference = node.item.variablesReference,
    })

    if err or not resp or #resp.variables == 0 then
        return false
    end

    for i, var in ipairs(resp.variables) do
        local child_item = {
            name = var.name,
            type = var.type,
            value = var.value,
            variablesReference = var.variablesReference,
            depth = node.item.depth + 1,
        }

        local child = Node.new(child_item, node)
        child.is_last_child = (i == #resp.variables)

        if child_item.name:match("^%d+$") then
            child_item.name = "[" .. child_item.name .. "]"
        end

        table.insert(node.children, child)
    end

    return true
end

---@async
---@return ow.dap.hover.Content
function Tree:render()
    if not self.root then
        return Content.new()
    end

    local content = Content.new()

    self:render_subtree(self.root, content)
    return content
end

---@async
---@param node ow.dap.hover.Node
---@param content ow.dap.hover.Content
function Tree:render_subtree(node, content)
    node:format_into(self.session, content)

    if node.is_expanded then
        for _, child in ipairs(node.children) do
            content:newline()
            self:render_subtree(child, content)
        end
    end
end

---@param node ow.dap.hover.Node
---@return integer
function Tree:count_subtree_nodes(node)
    local count = 1

    if node.is_expanded then
        for _, child in ipairs(node.children) do
            count = count + self:count_subtree_nodes(child)
        end
    end

    return count
end

---@param target_line integer
---@return ow.dap.hover.Node?
function Tree:get_node_at_line(target_line)
    local current_line = 0

    ---@param node ow.dap.hover.Node
    local function search(node)
        current_line = current_line + 1
        if current_line == target_line then
            return node
        end

        if node.is_expanded and node.children then
            for _, child in ipairs(node.children) do
                local found = search(child)
                if found then
                    return found
                end
            end
        end
    end

    if self.root then
        return search(self.root)
    end
end

---@async
---@param node ow.dap.hover.Node
---@return boolean success
function Tree:toggle_node(node)
    if not node.is_expanded then
        local success = self:load_children(node)
        if not success then
            return false
        end
    end

    node.is_expanded = not node.is_expanded
    return true
end

return Tree
