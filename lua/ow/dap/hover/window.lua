local Content = require("ow.dap.hover.content")
local log = require("ow.log")

---@class ow.dap.hover.Window
---@field NAMESPACE string
---@field NS_ID integer
---@field max_width? integer
---@field max_height? integer
---@field winid? integer
---@field bufnr? integer
---@field augroup? integer
---@field session dap.Session
---@field root ow.dap.hover.Node
local Window = {}
Window.__index = Window

Window.NAMESPACE = "ow.dap.hover.Window"
Window.NS_ID = vim.api.nvim_create_namespace(Window.NAMESPACE)

local function setup_highlights()
    vim.api.nvim_set_hl(0, "DapHoverPrefix", {
        link = "@comment",
    })
    vim.api.nvim_set_hl(0, "DapHoverExpandMarker", {
        link = "@comment",
    })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_highlights,
})

local instance = nil

---@param session dap.Session
---@return ow.dap.hover.Window
function Window.get_instance(session)
    if instance then
        return instance
    end

    instance = setmetatable({
        max_width = nil,
        max_height = nil,
        winid = nil,
        bufnr = nil,
        augroup = nil,
        session = session,
        root = nil,
    }, Window)

    return instance
end

function Window:destroy()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end

    if self.augroup then
        vim.api.nvim_del_augroup_by_id(self.augroup)
    end

    instance = nil
end

---@return integer
function Window:compute_width()
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true)
    local max_width = 1
    for _, line in ipairs(lines) do
        local line_width = vim.api.nvim_strwidth(line)
        if self.max_width and line_width >= self.max_width then
            max_width = self.max_width
            break
        end
        max_width = math.max(max_width, line_width)
    end

    return max_width
end

---@return integer
function Window:compute_height()
    local text_height = vim.api.nvim_win_text_height(self.winid, {}).all
    return math.min(self.max_height or text_height, text_height)
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

---@async
---@param node ow.dap.hover.Node
---@param start_line integer 1-indexed line number
---@param line_count integer number of lines to replace
function Window:refresh_tree(node, start_line, line_count)
    local content = Content.new()
    node:format_into(content)
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
    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
            local node = self.root:at(lnum)
            if not node or not node:is_expandable() then
                return
            end

            if not node.is_expanded then
                local success = node:load_children(self.session)
                if not success then
                    return
                end
            end

            local prev_size = node:size()
            node.is_expanded = not node.is_expanded
            self:refresh_tree(node, lnum, prev_size)
        end, debug.traceback)

        if not ok then
            log.error("Expansion failed:\n%s", err)
        end
    end)()
end

function Window:collapse_parent()
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
    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
            local node = self.root:at(lnum)
            if not node or not node:is_expandable() then
                return
            end

            local prev_size = node:size()
            node:expand_all(self.session)
            self:refresh_tree(node, lnum, prev_size)
        end, debug.traceback)

        if not ok then
            log.error("Expand all failed:\n%s", err)
        end
    end)()
end

function Window:collapse_all_at_cursor()
    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
            local node = self.root:at(lnum)
            if not node or not node:is_expandable() then
                return
            end

            local prev_size = node:size()
            node:collapse_all()
            self:refresh_tree(node, lnum, prev_size)
        end, debug.traceback)

        if not ok then
            log.error("Collapse all failed:\n%s", err)
        end
    end)()
end

---@return boolean success if parent line was found
function Window:goto_parent()
    local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
    local node = self.root:at(lnum)
    if not node or not node.parent then
        return false
    end

    local parent_line = self.root:index_of(node.parent)
    if parent_line then
        vim.api.nvim_win_set_cursor(self.winid, { parent_line, 0 })
        return true
    end

    return false
end

function Window:yank_value()
    local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
    local node = self.root:at(lnum)
    if not node then
        return
    end

    vim.fn.setreg('"', node.item.value)
    vim.fn.setreg("+", node.item.value)
end

---@async
---@param root ow.dap.hover.Node
function Window:show(root)
    self.root = root

    local prev_buf = vim.api.nvim_get_current_buf()
    self.bufnr = vim.api.nvim_create_buf(false, true)
    self.winid = vim.api.nvim_open_win(self.bufnr, false, {
        relative = "cursor",
        width = 1,
        height = 1,
        row = 1,
        col = 0,
        border = "rounded",
        style = "minimal",
    })
    vim.wo[self.winid].wrap = false

    self:refresh_tree(self.root, 1, 1)

    self.augroup =
        vim.api.nvim_create_augroup(Window.NAMESPACE, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
        group = self.augroup,
        buffer = prev_buf,
        once = true,
        callback = function()
            self:destroy()
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = self.augroup,
        callback = function(arg)
            if arg.buf ~= self.bufnr then
                self:destroy()
                return true
            end
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = self.augroup,
        once = true,
        pattern = tostring(self.winid),
        callback = function()
            self:destroy()
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
        self:destroy()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<Esc>", function()
        self:destroy()
    end, { buffer = self.bufnr, nowait = true })

    -- Yank operations
    vim.keymap.set("n", "y", function()
        self:yank_value()
    end, { buffer = self.bufnr, nowait = true })
end

return Window
