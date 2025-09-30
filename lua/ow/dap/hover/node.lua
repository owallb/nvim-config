local Item = require("ow.dap.item")
local log = require("ow.log")

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

---@return integer
function Node:size()
    local count = 1

    if self.is_expanded and self.children then
        for _, child in ipairs(self.children) do
            count = count + child:size()
        end
    end

    return count
end

---@param n integer
---@return ow.dap.hover.Node?
function Node:at(n)
    if n < 1 then
        return nil
    end

    local current = 0

    ---@param node ow.dap.hover.Node
    local function search(node)
        current = current + 1
        if current == n then
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

    return search(self)
end

---@param target ow.dap.hover.Node? if nil, returns index of self
---@return integer?
function Node:index_of(target)
    target = target or self
    local current = 0

    local function search(node)
        current = current + 1
        if node == target then
            return current
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

    return search(self)
end

---@param session dap.Session
function Node:expand_all(session)
    if not self:is_expandable() then
        return true
    end

    if not self.is_expanded then
        local success = self:load_children(session)
        if not success then
            return false
        end
        self.is_expanded = true
    end

    for _, child in ipairs(self.children) do
        local success = child:expand_all(session)
        if not success then
            return false
        end
    end

    return true
end

function Node:collapse_all()
    self.is_expanded = false
    for _, child in ipairs(self.children) do
        child:collapse_all()
    end
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

---@async
---@param session dap.Session
---@return boolean
function Node:load_children(session)
    if not self:is_container() or #self.children > 0 then
        return true -- Already loaded or not a container
    end

    local err, resp = session:request("variables", {
        variablesReference = self.item.variablesReference,
    })
    if err then
        log.warning("Failed to get variables for %s: %s", self.item.name, err)
    end
    if err or not resp or #resp.variables == 0 then
        return false
    end

    for i, var in ipairs(resp.variables) do
        local item = Item.from_var(var)
        local child = Node.new(item, self, self.lang)
        child.is_last_child = (i == #resp.variables)

        if item.name:match("^%d+$") then
            item.name = "[" .. item.name .. "]"
        end

        table.insert(self.children, child)
    end

    return true
end

return Node
