local Content = require("ow.dap.hover.content")
local Item = require("ow.dap.item")
local Node = require("ow.dap.hover.node")
local log = require("ow.log")

---@class ow.dap.hover.Tree
---@field lang string
---@field session dap.Session
---@field root ow.dap.hover.Node?
local Tree = {}
Tree.__index = Tree

---@param session dap.Session
---@return ow.dap.hover.Tree
function Tree.new(session)
    return setmetatable({
        lang = session.filetype,
        session = session,
        root = nil,
    }, Tree)
end

---@async
---@param item ow.dap.Item
function Tree:build(item)
    self.root = Node.new(item, nil, self.lang)

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
    if err then
        log.warning("Failed to get variables for %s: %s", node.item.name, err)
    end
    if err or not resp or #resp.variables == 0 then
        return false
    end

    for i, var in ipairs(resp.variables) do
        local item = Item.from_var(var)
        local child = Node.new(item, node, self.lang)
        child.is_last_child = (i == #resp.variables)

        if item.name:match("^%d+$") then
            item.name = "[" .. item.name .. "]"
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
    node:format_into(content)

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

---@param target_node ow.dap.hover.Node
---@return integer?
function Tree:get_line_for_node(target_node)
    local current_line = 0

    ---@param node ow.dap.hover.Node
    local function search(node)
        current_line = current_line + 1
        if node == target_node then
            return current_line
        end

        if node.is_expanded and node.children then
            for _, child in ipairs(node.children) do
                local found = search(child)
                if found then
                    return found
                end
            end
        end
        return nil
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

---@async
---@param node ow.dap.hover.Node
---@return boolean success
function Tree:expand_all_children(node)
    if not node:is_expandable() then
        return true
    end

    if not node.is_expanded then
        local success = self:load_children(node)
        if not success then
            return false
        end
        node.is_expanded = true
    end

    for _, child in ipairs(node.children) do
        local success = self:expand_all_children(child)
        if not success then
            return false
        end
    end

    return true
end

---@param node ow.dap.hover.Node
function Tree:collapse_all_children(node)
    node.is_expanded = false
    for _, child in ipairs(node.children) do
        self:collapse_all_children(child)
    end
end

return Tree
