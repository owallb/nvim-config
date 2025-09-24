-- https://github.com/mfussenegger/nvim-dap
local log = require("ow.log")

---@class Item
---@field name string
---@field type string
---@field value string
---@field variablesReference? number
---@field depth integer
local Item = {}
Item.__index = Item

---@param name string
---@param type string
---@param value string
---@param variablesReference? number
---@param depth integer
---@return Item
function Item.new(name, type, value, variablesReference, depth)
    return setmetatable({
        name = name,
        type = type,
        value = value,
        variablesReference = variablesReference,
        depth = depth,
    }, Item)
end

---@param var dap.Variable
---@param depth integer
---@return Item
function Item.from_var(var, depth)
    return Item.new(
        var.name,
        var.type,
        var.value,
        var.variablesReference,
        depth
    )
end

---@class FormatResult
---@field success boolean
---@field error? dap.ErrorResponse
---@field value? string
local FormatResult = {}
FormatResult.__index = FormatResult

---@param error? dap.ErrorResponse
---@param value? string
---@return FormatResult
function FormatResult.new(error, value)
    return setmetatable({
        success = not error and true or false,
        error = error,
        value = value,
    }, FormatResult)
end

---@class BaseFormatter
---@field session dap.Session
---@field MAX_DEPTH integer
---@field INDENT string
local BaseFormatter = {}
BaseFormatter.__index = BaseFormatter

BaseFormatter.MAX_DEPTH = 2
BaseFormatter.INDENT = "  "

---@return BaseFormatter
function BaseFormatter:new(session)
    return setmetatable({ session = session }, self)
end

---@param item Item
---@return FormatResult
---@diagnostic disable-next-line: unused-local
function BaseFormatter:format(item)
    return FormatResult.new(nil, item.value)
end

---@param item Item
---@return boolean
function BaseFormatter:is_container(item)
    return item.variablesReference and item.variablesReference > 0 or false
end

---@param level integer
---@return string
function BaseFormatter:make_indent(level)
    return string.rep(self.INDENT, level)
end

---@class CFormatter: BaseFormatter
local CFormatter = {}
CFormatter.__index = CFormatter
setmetatable(CFormatter, BaseFormatter)

CFormatter.MAX_ARR_ELEMENTS = 10
CFormatter.ARRAY_ELEM_PFX = ""
CFormatter.STRUCT_FIELD_PFX = "."
CFormatter.PLACEHOLDER = "..."

---@param item Item
---@return boolean
function CFormatter:is_pointer(item)
    return item.type:match("%*%s*[const%s]*[volatile%s]*[restrict%s]*$") ~= nil
end

---@param item Item
---@return boolean
function CFormatter:is_null_pointer(item)
    return self:is_pointer(item) and item.value:match("^0x0+$")
end

---@async
---@param item Item
---@return FormatResult
function CFormatter:format_pointer(item)
    if self:is_null_pointer(item) then
        return FormatResult.new(nil, "nullptr")
    elseif not item.value:match("^0x%x+$") then
        -- Value contains more than just a pointer address
        -- (e.g., "0x12345 \"hello\"" for char*)
        -- Remove the leading address to show just the meaningful content
        return FormatResult.new(nil, item.value:gsub("^0x%x+%s*", ""))
    elseif
        item.depth == CFormatter.MAX_DEPTH
        or not self:is_container(item)
    then
        return FormatResult.new(nil, item.value)
    end

    local err, resp = self.session:request("variables", {
        variablesReference = item.variablesReference,
    })
    if err or not resp then
        return FormatResult.new(err)
    end

    if #resp.variables == 0 then
        return FormatResult.new(nil, item.value)
    elseif #resp.variables == 1 then
        local var = resp.variables[1]
        local inner = Item.from_var(var, item.depth)
        return self:format_value(inner)
    else
        return self:format_container(item, resp.variables)
    end
end

---@async
---@param item Item
---@param vars dap.Variable[]?
---@return FormatResult
function CFormatter:format_container(item, vars)
    if item.depth >= CFormatter.MAX_DEPTH then
        return FormatResult.new(
            nil,
            vim.trim(item.value) ~= "" and item.value
                or string.format("{%s}", CFormatter.PLACEHOLDER)
        )
    end

    if not vars then
        local err, resp = self.session:request("variables", {
            variablesReference = item.variablesReference,
        })
        if err or not resp then
            return FormatResult.new(err)
        end

        vars = resp.variables
    end

    if #vars == 0 then
        return FormatResult.new(nil, item.value)
    end

    ---@type Item[]
    local items = {}
    for _, var in ipairs(vars) do
        table.insert(items, Item.from_var(var, item.depth + 1))
    end

    local is_array = false
    local pfx
    if items[1].name:match("^%[?%d+%]?$") then
        is_array = true
        pfx = CFormatter.ARRAY_ELEM_PFX
    else
        pfx = CFormatter.STRUCT_FIELD_PFX
    end

    local indent = self:make_indent(items[1].depth)
    local content = "{\n"

    for i, inner in ipairs(items) do
        if is_array and i > CFormatter.MAX_ARR_ELEMENTS then
            content = content
                .. string.format("%s%s\n", indent, CFormatter.PLACEHOLDER)
            break
        end

        if is_array and inner.name:match("^%d+$") then
            inner.name = "[" .. inner.name .. "]"
        end

        local res = self:format(inner)
        if not res.success then
            return res
        end

        content = content .. string.format("%s%s%s,\n", indent, pfx, res.value)
    end

    content = content .. self:make_indent(item.depth) .. "}"
    return FormatResult.new(nil, content)
end

---@async
---@param item Item
---@return FormatResult
function CFormatter:format_value(item)
    if self:is_pointer(item) then
        return self:format_pointer(item)
    elseif self:is_container(item) then
        return self:format_container(item)
    else
        return FormatResult.new(nil, item.value)
    end
end

---@async
---@param item Item
---@return FormatResult
function CFormatter:format(item)
    local res = self:format_value(item)
    if not res.success then
        return res
    end

    if self:is_container(item) and not self:is_null_pointer(item) then
        local value = string.format(
            "%s(%s) %s",
            item.name ~= "" and string.format("%s = ", item.name) or "",
            item.type,
            res.value
        )
        return FormatResult.new(nil, value)
    else
        local value = string.format("%s = %s", item.name, res.value)
        return FormatResult.new(nil, value)
    end
end

---@class HoverState
---@field MAX_WIDTH integer
---@field MAX_HEIGHT integer
---@field current_win? integer
---@field session dap.Session
---@field frame_id number
---@field line_nr integer
---@field col_nr integer
---@field current_file string
---@field lines string[]
---@field depth integer
local HoverState = {}
HoverState.__index = HoverState

HoverState.MAX_WIDTH = 80
HoverState.MAX_HEIGHT = 20

function HoverState.new(session, frame_id, line_nr, col_nr, current_file)
    return setmetatable({
        session = session,
        frame_id = frame_id,
        line_nr = line_nr,
        col_nr = col_nr,
        current_file = current_file,
        lines = {},
        depth = 0,
    }, HoverState)
end

function HoverState.close()
    if
        HoverState.current_win
        and vim.api.nvim_win_is_valid(HoverState.current_win)
    then
        vim.api.nvim_win_close(HoverState.current_win, true)
    end
    HoverState.current_win = nil
end

---@param content string
function HoverState:render(content)
    local lines = vim.split(content, "\n")
    local filetype = self.session.filetype

    local orig_buf = vim.api.nvim_get_current_buf()
    local hover_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(hover_buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value(
        "filetype",
        filetype or self.session.filetype,
        { buf = hover_buf }
    )

    local max_width = 0
    for _, line in ipairs(lines) do
        if #line >= HoverState.MAX_WIDTH then
            max_width = HoverState.MAX_WIDTH
            break
        end
        max_width = math.max(max_width, #line)
    end

    if max_width == 0 then
        return
    end

    local win = vim.api.nvim_open_win(hover_buf, false, {
        relative = "cursor",
        width = max_width,
        height = 1,
        row = 1,
        col = 0,
        border = "rounded",
        style = "minimal",
        hide = true,
    })

    vim.api.nvim_win_set_config(win, {
        height = math.min(
            HoverState.MAX_HEIGHT,
            vim.api.nvim_win_text_height(win, {}).all
        ),
        hide = false,
    })

    HoverState.current_win = win

    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
        buffer = orig_buf,
        once = true,
        callback = HoverState.close,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = hover_buf,
        once = true,
        callback = HoverState.close,
    })
end

---@return BaseFormatter
function HoverState:get_formatter()
    local filetype = self.session.filetype
    if filetype == "c" or filetype == "cpp" then
        return CFormatter:new(self.session)
    else
        return BaseFormatter:new(self.session)
    end
end

---@async
---@param expr string
---@return dap.ErrorResponse?, string?
function HoverState:eval(expr)
    local request = {
        expression = expr,
        frameId = self.frame_id,
        context = "hover",
        line = self.line_nr,
        column = self.col_nr,
        source = {
            path = self.current_file,
        },
    }

    local eval
    do
        local err, resp = self.session:request("evaluate", request)
        if err or not resp then
            return err
        end

        eval = resp
    end

    local fmt = self:get_formatter()
    local res = fmt:format(
        Item.new(expr, eval.type, eval.result, eval.variablesReference, 0)
    )
    if not res.success then
        return res.error
    end

    return nil, res.value
end

---@async
local function hover_async()
    if
        HoverState.current_win
        and vim.api.nvim_win_is_valid(HoverState.current_win)
    then
        vim.api.nvim_set_current_win(HoverState.current_win)
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

    local state =
        HoverState.new(session, frame_id, line_nr, col_nr, current_file)

    local err, resp = state:eval(expr)
    if err or not resp then
        log.warning("Failed to evaluate '%s': %s", expr, err)
        return
    end

    state:render(resp)
end

local function hover()
    coroutine.wrap(function()
        local ok, err = xpcall(hover_async, debug.traceback)
        if not ok then
            log.error("Hover failed:\n%s", err)
        end
    end)()
end

---@type LazyPluginSpec
return {
    "mfussenegger/nvim-dap",
    keys = {
        {
            "<Leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
        },
        {
            "<Leader>df",
            function()
                require("dap").focus_frame()
            end,
        },
        {
            "<C-S-i>",
            function()
                require("dap").up()
            end,
        },
        {
            "<C-S-o>",
            function()
                require("dap").down()
            end,
        },
        {
            "<Leader>dk",
            hover,
            mode = { "n", "x" },
        },
        {
            "<Leader>dr",
            function()
                require("dap").repl.toggle()
            end,
            mode = { "n", "x" },
        },
        {
            "<F2>",
            function()
                require("dap").step_into()
            end,
        },
        {
            "<F3>",
            function()
                require("dap").step_over()
            end,
        },
        {
            "<F4>",
            function()
                require("dap").step_out()
            end,
        },
        {
            "<F5>",
            function()
                require("dap").continue()
            end,
        },
        {
            "<F9>",
            function()
                require("dap").terminate()
            end,
        },
    },
    config = function()
        local dap = require("dap")

        vim.api.nvim_set_hl(0, "DebugPC", {
            bg = "NONE",
            fg = "NONE",
        })

        vim.api.nvim_create_user_command(
            "Debug",
            ---@param opts vim.api.keyset.create_user_command.command_args
            function(opts)
                local cfgs = dap.configurations[vim.bo.filetype]
                if not cfgs then
                    log.error(
                        "No configurations available for filetype %s",
                        vim.bo.filetype
                    )
                    return
                end

                local function run_config(cfg)
                    local all_args = vim.fn.split(opts.args)
                    cfg.program = all_args[1]

                    local args = {}
                    for i = 2, #all_args do
                        table.insert(args, all_args[i])
                    end
                    cfg.args = args

                    dap.run(cfg)
                end

                if #cfgs == 1 then
                    run_config(cfgs[1])
                    return
                end

                local names = {}
                for _, c in ipairs(cfgs) do
                    table.insert(names, c.name)
                end

                vim.ui.select(names, {
                    prompt = "Select DAP configuration to use:",
                }, function(choice, idx)
                    if choice and idx then
                        run_config(cfgs[idx])
                    end
                end)
            end,
            {
                nargs = "+",
                ---@param ArgLead string
                ---@param CmdLine string
                complete = function(ArgLead, CmdLine, CursorPos)
                    local _, spaces = CmdLine:sub(1, CursorPos):gsub("%s+", "")

                    if spaces == 1 then
                        return vim.fn.getcompletion(ArgLead, "file")
                    end
                end,
            }
        )

        -- https://sourceware.org/gdb/current/onlinedocs/gdb#Debugger-Adapter-Protocol
        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap" },
        }

        dap.adapters.lldb = {
            type = "executable",
            command = "lldb-dap",
        }

        dap.adapters.python = {
            type = "executable",
            command = "python",
            args = { "-m", "debugpy.adapter" },
        }

        dap.configurations.c = {
            {
                type = "gdb",
                request = "launch",
                name = "Launch",
                program = function()
                    local path = vim.fn.input({
                        prompt = "Path to executable: ",
                        default = vim.fn.getcwd() .. "/",
                        completion = "file",
                    })
                    return (path and path ~= "") and path or dap.ABORT
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }

        -- dap.configurations.c = {
        --     {
        --         type = "lldb",
        --         request = "launch",
        --         name = "Launch",
        --         program = function()
        --             local path = vim.fn.input({
        --                 prompt = "Path to executable: ",
        --                 default = vim.fn.getcwd() .. "/",
        --                 completion = "file",
        --             })
        --             return (path and path ~= "") and path or dap.ABORT
        --         end,
        --         cwd = "${workspaceFolder}",
        --         stopAtBeginningOfMainSubprogram = false,
        --         console = "internalConsole",
        --     },
        -- }

        dap.configurations.cpp = dap.configurations.c

        dap.configurations.python = {
            {
                type = "python",
                request = "launch",
                name = "Launch",
                program = function()
                    local path = vim.fn.input({
                        prompt = "Path to executable: ",
                        default = vim.fn.getcwd() .. "/",
                        completion = "file",
                    })
                    return (path and path ~= "") and path or dap.ABORT
                end,
                cwd = "${workspaceFolder}",
            },
        }
    end,
}
