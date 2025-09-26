-- Tree-based DAP variable formatter with expand/collapse support
local Content = require("ow.dap.hover.content")
local Node = require("ow.dap.hover.node")
local log = require("ow.log")

---@class ow.dap.hover.Tree
---@field session dap.Session
---@field root_node ow.dap.hover.Node?
---@field line_to_node table<integer, ow.dap.hover.Node> Map line numbers to nodes
---@field extmark_to_node table<integer, ow.dap.hover.Node> Map extmark IDs to nodes
local Tree = {}
Tree.__index = Tree

---Create a new tree formatter
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

---Build the tree from a DAP item (async)
---@async
---@param item ow.dap.Item Root item to build tree from
---@return ow.dap.hover.Node
function Tree:build(item)
    local root = Node.new(item, nil)
    self.root_node = root

    -- For now, start with everything collapsed
    -- Later we can add logic to expand first level by default
    return root
end

---Load children for a node (async)
---@async
---@param node ow.dap.hover.Node
---@return boolean success Whether loading succeeded
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

    -- Create child nodes
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

        -- Format array indices properly
        if child_item.name:match("^%d+$") then
            child_item.name = "[" .. child_item.name .. "]"
        end

        table.insert(node.children, child)
    end

    return true
end

---Render the tree to highlighted content
---@async
---@return ow.dap.hover.Content
function Tree:render()
    if not self.root_node then
        return Content.new()
    end

    local content = Content.new()
    self.line_to_node = {}

    self:render_node(self.root_node, content, 0)
    return content
end

---Render a single node and its expanded children
---@async
---@param node ow.dap.hover.Node
---@param content ow.dap.hover.Content
---@param line_number integer Current line number
---@return integer new_line_number Updated line number after rendering
function Tree:render_node(node, content, line_number)
    -- Store line mapping
    node.line_number = line_number
    self.line_to_node[line_number] = node

    -- Format this node
    local node_content = node:format(self.session)
    content.text = content.text .. node_content.text

    -- Copy highlights, adjusting for current position
    local text_offset = #content.text - #node_content.text
    for _, highlight in ipairs(node_content.highlights) do
        table.insert(content.highlights, {
            group = highlight.group,
            start_col = highlight.start_col + text_offset,
            end_col = highlight.end_col + text_offset,
        })
    end

    content:newline()
    line_number = line_number + 1

    -- Render expanded children
    if node.is_expanded then
        for _, child in ipairs(node.children) do
            line_number = self:render_node(child, content, line_number)
        end
    end

    return line_number
end

---Toggle expansion state of node at given line
---@async
---@param line_number integer
---@return boolean success Whether toggle succeeded
function Tree:toggle_at_line(line_number)
    local node = self.line_to_node[line_number]
    if not node or not node:is_container() then
        return false
    end

    if not node.is_expanded then
        -- Expanding: load children if needed
        local success = self:load_children(node)
        if not success then
            return false
        end
    end

    -- Toggle state
    node.is_expanded = not node.is_expanded
    return true
end

return Tree
