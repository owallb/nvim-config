local Content = require("ow.dap.hover.content")
local Item = require("ow.dap.item")
local Tree = require("ow.dap.hover.tree")
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
    if not instance then
        instance = setmetatable({
            max_width = nil,
            max_height = nil,
            winid = nil,
            bufnr = nil,
            augroup = nil,
        }, Window)
    end

    return instance
end

function Window:close()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end

    if self.augroup then
        vim.api.nvim_del_augroup_by_id(self.augroup)
    end

    self.augroup = nil
    self.winid = nil
    self.bufnr = nil
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

---@param lines string[]
---@param content ow.dap.hover.Content
function Window:show(lines, content)
    local prev_buf = vim.api.nvim_get_current_buf()
    self.bufnr = vim.api.nvim_create_buf(false, true)

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
        callback = self.close,
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

    vim.keymap.set(
        "n",
        "<CR>",
        self.expand_at_cursor,
        { buffer = self.bufnr, nowait = true }
    )

    vim.keymap.set(
        "n",
        "<Tab>",
        self.expand_at_cursor,
        { buffer = self.bufnr, nowait = true }
    )
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
            local text_height =
                vim.api.nvim_win_text_height(self.winid, {}).all
            vim.api.nvim_win_set_config(self.winid, {
                height = math.min(
                    self.max_height or text_height,
                    text_height
                ),
            })
        end, debug.traceback)

        if not ok then
            log.error("Expansion failed:\n%s", err)
        end
    end)()
end

---Main hover entry point
---@async
---@param expr string Expression to evaluate
---@param session dap.Session DAP session
---@param frame_id number Current frame ID
---@param line_nr integer Line number for context
---@param col_nr integer Column number for context
---@param current_file string Current file path
local function hover_eval(
    expr,
    session,
    frame_id,
    line_nr,
    col_nr,
    current_file
)
    local win = Window.get_instance()
    -- Close existing hover window
    win:close()

    -- Evaluate expression
    local eval_request = {
        expression = expr,
        frameId = frame_id,
        context = "hover",
        line = line_nr,
        column = col_nr,
        source = {
            path = current_file,
        },
    }

    local err, resp = session:request("evaluate", eval_request)
    if err or not resp then
        log.warning("Failed to evaluate '%s': %s", expr, err)
        return
    end

    -- Create item and tree formatter
    local item =
        Item.new(expr, resp.type, resp.result, resp.variablesReference, 0)
    local tree = Tree.new(session)

    -- Build and render tree
    tree:build(item)
    local content = tree:render()
    local lines = content:get_lines()

    -- Store formatter for expansion
    win.tree = tree

    -- Show hover window
    win:show(lines, content)
end

---Public hover function
---@async
local function hover_async()
    -- Check if hover window is already open - focus it instead
    local win = Window.get_instance()
    if win.winid and vim.api.nvim_win_is_valid(win.winid) then
        vim.api.nvim_set_current_win(win.winid)
        return
    end

    local dap = require("dap")
    local session = dap.session()
    if not session then
        return
    end

    local capabilities = session.capabilities or {}
    local supports_hover = capabilities.supportsEvaluateForHovers
    if not supports_hover then
        log.warning("Hover is not supported by this adapter")
        return
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_nr = cursor_pos[1] -- nvim-dap sets linesStartAt1=true
    local col_nr = cursor_pos[2] + 1 -- nvim-dap sets columnsStartAt1=true
    local current_file = vim.api.nvim_buf_get_name(0)

    -- Get expression under cursor
    local expr
    local mode = vim.api.nvim_get_mode()
    if mode.mode == "v" then
        -- Visual mode selection
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        local start_row, start_col = start_pos[2], start_pos[3]
        local end_row, end_col = end_pos[2], end_pos[3]

        if start_row == end_row and end_col < start_col then
            start_col, end_col = end_col, start_col
        elseif end_row < start_row then
            start_row, end_row = end_row, start_row
            start_col, end_col = end_col, start_col
        end

        local lines = vim.api.nvim_buf_get_text(
            0,
            start_row - 1,
            start_col - 1,
            end_row - 1,
            end_col,
            {}
        )
        expr = table.concat(lines, "\n")

        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<ESC>", true, false, true),
            "n",
            false
        )
    else
        expr = vim.fn.expand("<cexpr>")
    end

    if expr == "" then
        return
    end

    -- Get thread and frame information
    local thread_id
    do
        local err, resp = session:request("threads", nil)
        if err or not resp or #resp.threads == 0 then
            log.warning("Failed to get threads: %s", err)
            return
        end
        thread_id = resp.threads[1].id
    end

    local frame_id
    do
        local err, resp =
            session:request("stackTrace", { threadId = thread_id })
        if err or not resp or #resp.stackFrames == 0 then
            log.warning("Failed to get stack trace: %s", err)
            return
        end
        frame_id = resp.stackFrames[1].id
    end

    -- Evaluate and display hover
    hover_eval(expr, session, frame_id, line_nr, col_nr, current_file)
end

---Wrapped hover function with error handling
local function hover()
    coroutine.wrap(function()
        local ok, err = xpcall(hover_async, debug.traceback)
        if not ok then
            log.error("Hover failed:\n%s", err)
        end
    end)()
end

return hover
