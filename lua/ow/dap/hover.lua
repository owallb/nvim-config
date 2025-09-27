local Item = require("ow.dap.item")
local Tree = require("ow.dap.hover.tree")
local Window = require("ow.dap.hover.window")
local log = require("ow.log")

---@async
---@param expr string
---@param session dap.Session
---@param frame_id number
---@param line_nr integer
---@param col_nr integer
---@param current_file string
local function eval(expr, session, frame_id, line_nr, col_nr, current_file)
    local win = Window.get_instance()
    win:close()

    local request = {
        expression = expr,
        frameId = frame_id,
        context = "hover",
        line = line_nr,
        column = col_nr,
        source = {
            path = current_file,
        },
    }

    local err, resp = session:request("evaluate", request)
    if err then
        log.warning("Failed to evaluate '%s': %s", expr, err)
    end
    if err or not resp then
        return
    end

    local item = Item.new(expr, resp.type, resp.result, resp.variablesReference)
    win.tree = Tree.new(session)

    win.tree:build(item)
    local content = win.tree:render()

    win:show(content)
end

---@async
local function hover_async()
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

    local expr
    local mode = vim.api.nvim_get_mode()
    if mode.mode == "v" then
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

    local thread_id
    do
        local err, resp = session:request("threads", nil)
        if err then
            log.warning("Failed to get threads: %s", err)
        end
        if err or not resp or #resp.threads == 0 then
            return
        end
        thread_id = resp.threads[1].id
    end

    local frame_id
    do
        local err, resp =
            session:request("stackTrace", { threadId = thread_id })
        if err then
            log.warning("Failed to get stack trace: %s", err)
        end
        if err or not resp or #resp.stackFrames == 0 then
            return
        end
        frame_id = resp.stackFrames[1].id
    end

    eval(expr, session, frame_id, line_nr, col_nr, current_file)
end

local function hover()
    coroutine.wrap(function()
        local ok, err = xpcall(hover_async, debug.traceback)
        if not ok then
            log.error("Hover failed:\n%s", err)
        end
    end)()
end

return hover
