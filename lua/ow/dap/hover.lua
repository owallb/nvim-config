-- DAP hover implementation with tree-based display
local Content = require("ow.dap.hover.content")
local Item = require("ow.dap.item")
local Tree = require("ow.dap.hover.tree")
local log = require("ow.log")

---@class ow.dap.hover.Window
---@field current_win? integer Currently active hover window ID
---@field ns_id integer Namespace for extmarks
---@field tree ow.dap.hover.Tree? Current tree formatter
local Window = {}

Window.MAX_WIDTH = nil
Window.MAX_HEIGHT = nil
Window.ns_id = vim.api.nvim_create_namespace("ow.dap.hover")

---Close any existing hover window
function Window.close()
    if Window.current_win and vim.api.nvim_win_is_valid(Window.current_win) then
        vim.api.nvim_win_close(Window.current_win, true)
    end
    Window.current_win = nil
    Window.tree = nil
end

---@param lines string[]
---@return integer
function Window.compute_width(lines)
    local max_width = 1
    for _, line in ipairs(lines) do
        if Window.MAX_WIDTH and #line >= Window.MAX_WIDTH then
            max_width = Window.MAX_WIDTH
            break
        end
        max_width = math.max(max_width, #line)
    end

    return max_width
end

---Create and display hover window with tree content
---@param lines string[]
---@param content ow.dap.hover.Content
function Window.show(lines, content)
    -- Create buffer
    local orig_buf = vim.api.nvim_get_current_buf()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    -- Create window (initially hidden for size calculation)
    local win = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        width = Window.compute_width(lines),
        height = 1,
        row = 1,
        col = 0,
        border = "rounded",
        style = "minimal",
        hide = true,
    })

    -- Calculate and apply final height
    local text_height = vim.api.nvim_win_text_height(win, {}).all
    vim.api.nvim_win_set_config(win, {
        height = math.min(Window.MAX_HEIGHT or text_height, text_height),
        hide = false,
    })

    -- Apply syntax highlighting
    content:apply_highlights(Window.ns_id, buf, 0)

    -- Store window reference
    Window.current_win = win

    -- Set up auto-close behavior
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
        buffer = orig_buf,
        once = true,
        callback = Window.close,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = buf,
        once = true,
        callback = Window.close,
    })

    -- Set up expansion keymaps
    vim.keymap.set("n", "<CR>", function()
        Window.expand_at_cursor(buf)
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "<Tab>", function()
        Window.expand_at_cursor(buf)
    end, { buffer = buf, nowait = true })
end

---@param buf integer
---@param callback fun()
function Window.update_buffer(buf, callback)
    local prev_scrolloff = vim.wo[Window.current_win].scrolloff
    vim.wo[Window.current_win].scrolloff = 0
    vim.bo[buf].modifiable = true
    callback()
    vim.bo[buf].modifiable = false
    vim.wo[Window.current_win].scrolloff = prev_scrolloff
end

---Expand/collapse item at cursor position
---@param buf integer
function Window.expand_at_cursor(buf)
    if not Window.tree then
        return
    end

    -- Re-render the tree
    coroutine.wrap(function()
        local ok, err = xpcall(function()
            -- Toggle expansion
            local lnum = vim.api.nvim_win_get_cursor(Window.current_win)[1]
            local node = Window.tree:get_node_at_line(lnum)
            if not node or not node:is_container() then
                return
            end

            local prev_node_count = Window.tree:count_subtree_nodes(node)

            local success = Window.tree:toggle_node(node)
            if not success then
                return
            end

            local content = Content.new()
            Window.tree:render_subtree(node, content)
            local lines = content:get_lines()

            Window.update_buffer(buf, function()
                vim.api.nvim_buf_set_lines(
                    buf,
                    lnum - 1,
                    lnum - 1 + prev_node_count,
                    true,
                    lines
                )
            end)

            -- Apply highlights
            content:apply_highlights(Window.ns_id, buf, lnum - 1)

            -- Adjust window size
            local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
            vim.api.nvim_win_set_config(Window.current_win, {
                width = Window.compute_width(all_lines),
            })
            local text_height =
                vim.api.nvim_win_text_height(Window.current_win, {}).all
            vim.api.nvim_win_set_config(Window.current_win, {
                height = math.min(
                    Window.MAX_HEIGHT or text_height,
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
    -- Close existing hover window
    Window.close()

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
    Window.tree = tree

    -- Show hover window
    Window.show(lines, content)
end

---Public hover function
---@async
local function hover_async()
    -- Check if hover window is already open - focus it instead
    if Window.current_win and vim.api.nvim_win_is_valid(Window.current_win) then
        vim.api.nvim_set_current_win(Window.current_win)
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
