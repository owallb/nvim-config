local Content = require("ow.dap.hover.content")
local log = require("ow.log")

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

    vim.keymap.set("n", "<CR>", function()
        self:expand_at_cursor()
    end, { buffer = self.bufnr, nowait = true })

    vim.keymap.set("n", "<Tab>", function()
        self:expand_at_cursor()
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

function Window:expand_at_cursor()
    if not self.tree then
        return
    end

    coroutine.wrap(function()
        local ok, err = xpcall(function()
            local lnum = vim.api.nvim_win_get_cursor(self.winid)[1]
            local node = self.tree:get_node_at_line(lnum)
            if not node or not node:is_container() then
                return
            end

            local prev_node_count = self.tree:count_subtree_nodes(node)

            local success = self.tree:toggle_node(node)
            if not success then
                return
            end

            local content = Content.new()
            self.tree:render_subtree(node, content)
            local lines = content:get_lines()

            self:update_buffer(function()
                vim.api.nvim_buf_set_lines(
                    self.bufnr,
                    lnum - 1,
                    lnum - 1 + prev_node_count,
                    true,
                    lines
                )
            end)

            content:apply_highlights(Window.NS_ID, self.bufnr, lnum - 1)

            vim.api.nvim_win_set_config(self.winid, {
                width = self:compute_width(),
            })
            local text_height = vim.api.nvim_win_text_height(self.winid, {}).all
            vim.api.nvim_win_set_config(self.winid, {
                height = math.min(self.max_height or text_height, text_height),
            })
        end, debug.traceback)

        if not ok then
            log.error("Expansion failed:\n%s", err)
        end
    end)()
end

return Window
