local Content = require("ow.dap.hover.content")
local log = require("ow.log")

---@class ow.dap.hover.NodeInfo
---@field node ow.dap.hover.Node?
---@field line_number integer
---@field subtree_count integer
local NodeInfo = {}
NodeInfo.__index = NodeInfo

---@param node ow.dap.hover.Node?
---@param line_number integer
---@param subtree_count integer
---@return ow.dap.hover.NodeInfo
function NodeInfo.new(node, line_number, subtree_count)
    return setmetatable({
        node = node,
        line_number = line_number,
        subtree_count = subtree_count,
    }, NodeInfo)
end

---@return boolean
function NodeInfo:is_valid()
    return self.node ~= nil
end

---@class ow.dap.hover.Window
---@field NAMESPACE string
---@field max_width? integer
---@field max_height? integer
---@field winid? integer
---@field bufnr? integer
---@field NS_ID integer
---@field augroup? integer
---@field tree ow.dap.hover.Tree?
local Window = {}
Window.__index = Window

Window.NAMESPACE = "ow.dap.hover.Window"
Window.NS_ID = vim.api.nvim_create_namespace(Window.NAMESPACE)

local instance = nil

---@return ow.dap.hover.Window
function Window.get_instance()
    if instance then
        return instance
    end

    instance = setmetatable({
        max_width = nil,
        max_height = nil,
        winid = nil,
        bufnr = nil,
        augroup = nil,
    }, Window)

    return instance
end

function Window:close()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end

    if self.augroup then
        vim.api.nvim_del_augroup_by_id(self.augroup)
    end

    self.max_width = nil
    self.max_height = nil
    self.winid = nil
    self.bufnr = nil
    self.augroup = nil
    self.tree = nil
end

---@return integer
function Window:compute_width()
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true)
    local max_width = 1
    for _, line in ipairs(lines) do
        if self.max_width and #line >= self.max_width then
            max_width = self.max_width
            break
        end
        max_width = math.max(max_width, #line)
    end

    return max_width
end

---@return integer
function Window:compute_height()
    local text_height = vim.api.nvim_win_text_height(self.winid, {}).all
    return math.min(self.max_height or text_height, text_height)
end

---@param content ow.dap.hover.Content
function Window:show(content)
    local prev_buf = vim.api.nvim_get_current_buf()
    self.bufnr = vim.api.nvim_create_buf(false, true)

    local lines = content:get_lines()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
    vim.bo[self.bufnr].modifiable = false

    self.winid = vim.api.nvim_open_win(self.bufnr, false, {
        relative = "cursor",
        width = self:compute_width(),
        height = 1,
        row = 1,
        col = 0,
        border = "rounded",
        style = "minimal",
        hide = true,
    })

    vim.api.nvim_win_set_config(self.winid, {
        height = self:compute_height(),
        hide = false,
    })

    content:apply_highlights(Window.NS_ID, self.bufnr, 0)

    self.augroup =
        vim.api.nvim_create_augroup(Window.NAMESPACE, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
        group = self.augroup,
        buffer = prev_buf,
        once = true,
        callback = function()
            self:close()
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = self.augroup,
        callback = function(arg)
            if arg.buf ~= self.bufnr then
                self:close()
                return true
            end
        end,
    })

    -- Toggle expand/collapse
    vim.keymap.set("n", "<CR>", function()
        self:toggle_node()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<Tab>", function()
        self:toggle_node()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<Space>", function()
        self:toggle_node()
    end, { buffer = self.bufnr, nowait = true })

    -- Collapse
    vim.keymap.set("n", "<S-Tab>", function()
        self:collapse_parent()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<BS>", function()
        self:collapse_parent()
    end, { buffer = self.bufnr, nowait = true })

    -- Tree operations
    vim.keymap.set("n", "E", function()
        self:expand_all_at_cursor()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "C", function()
        self:collapse_all_at_cursor()
    end, { buffer = self.bufnr, nowait = true })

    -- Navigation
    vim.keymap.set("n", "p", function()
        self:goto_parent()
    end, { buffer = self.bufnr, nowait = true })

    -- Quick actions
    vim.keymap.set("n", "q", function()
        self:close()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<Esc>", function()
        self:close()
    end, { buffer = self.bufnr, nowait = true })

    -- Yank operations
    vim.keymap.set("n", "y", function()
        self:yank_value()
    end, { buffer = self.bufnr, nowait = true })
end

---@param callback fun()
function Window:update_buffer(callback)
    local prev_scrolloff = vim.wo[self.winid].scrolloff
    vim.wo[self.winid].scrolloff = 0
    vim.bo[self.bufnr].modifiable = true
    callback()
    vim.bo[self.bufnr].modifiable = false
    vim.wo[self.winid].scrolloff = prev_scrolloff
end

---@return ow.dap.hover.NodeInfo
function Window:get_current_node_info()
    local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
    local node = self.tree:get_node_at_line(lnum)

    if not node then
        return NodeInfo.new(nil, lnum, 0)
    end

    local subtree_count = self.tree:count_subtree_nodes(node)
    return NodeInfo.new(node, lnum, subtree_count)
end

---@async
---@param node ow.dap.hover.Node
---@param start_line integer 1-indexed line number
---@param line_count integer number of lines to replace
function Window:refresh_subtree(node, start_line, line_count)
    local content = Content.new()
    self.tree:render_subtree(node, content)
    local lines = content:get_lines()

    self:update_buffer(function()
        vim.api.nvim_buf_set_lines(
            self.bufnr,
            start_line - 1,
            start_line - 1 + line_count,
            true,
            lines
        )
    end)

    content:apply_highlights(Window.NS_ID, self.bufnr, start_line - 1)

    vim.api.nvim_win_set_config(self.winid, {
        width = self:compute_width(),
    })
    vim.api.nvim_win_set_config(self.winid, {
        height = self:compute_height(),
    })
end

function Window:toggle_node()
    if not self.tree then
        return
    end

    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local info = self:get_current_node_info()
            if not info:is_valid() or not info.node:is_expandable() then
                return
            end

            local success = self.tree:toggle_node(info.node)
            if not success then
                return
            end

            self:refresh_subtree(
                info.node,
                info.line_number,
                info.subtree_count
            )
        end, debug.traceback)

        if not ok then
            log.error("Expansion failed:\n%s", err)
        end
    end)()
end

function Window:collapse_parent()
    if not self.tree then
        return
    end

    coroutine.wrap(function()
        local ok, err = xpcall(function()
            if self:goto_parent() then
                self:toggle_node()
            end
        end, debug.traceback)

        if not ok then
            log.error("Collapse failed:\n%s", err)
        end
    end)()
end

function Window:expand_all_at_cursor()
    if not self.tree then
        return
    end

    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local info = self:get_current_node_info()
            if not info:is_valid() or not info.node:is_expandable() then
                return
            end

            local success = self.tree:expand_all_children(info.node)
            if not success then
                return
            end

            self:refresh_subtree(
                info.node,
                info.line_number,
                info.subtree_count
            )
        end, debug.traceback)

        if not ok then
            log.error("Expand all failed:\n%s", err)
        end
    end)()
end

function Window:collapse_all_at_cursor()
    if not self.tree then
        return
    end

    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local info = self:get_current_node_info()
            if not info:is_valid() or not info.node:is_container() then
                return
            end

            self.tree:collapse_all_children(info.node)
            self:refresh_subtree(
                info.node,
                info.line_number,
                info.subtree_count
            )
        end, debug.traceback)

        if not ok then
            log.error("Collapse all failed:\n%s", err)
        end
    end)()
end

---@return boolean success if parent line was found
function Window:goto_parent()
    if not self.tree then
        return false
    end

    local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
    local node = self.tree:get_node_at_line(lnum)
    if not node or not node.parent then
        return false
    end

    local parent_line = self.tree:get_line_for_node(node.parent)
    if parent_line then
        vim.api.nvim_win_set_cursor(self.winid, { parent_line, 0 })
        return true
    end

    return false
end

function Window:yank_value()
    if not self.tree then
        return
    end

    local info = self:get_current_node_info()
    if not info:is_valid() then
        return
    end

    vim.fn.setreg('"', info.node.item.value)
    vim.fn.setreg("+", info.node.item.value)
end

return Window
