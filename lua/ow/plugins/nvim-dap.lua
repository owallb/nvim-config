-- https://github.com/mfussenegger/nvim-dap
local log = require("ow.log")

local Hover = {}

---@param filetype string
---@param lines string[]
function Hover.show_lines(filetype, lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })

    local max_width = 0
    for _, line in ipairs(lines) do
        max_width = math.max(max_width, #line)
    end

    if max_width == 0 then
        return
    end

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        width = math.min(80, max_width),
        height = math.min(20, #lines),
        row = 1,
        col = 0,
        border = "rounded",
        style = "minimal",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "InsertEnter" }, {
        once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
    })
end

---@param frame_id integer
---@param expr string
---@param eval_resp dap.EvaluateResponse
---@param variables dap.Variable[]
---@param callback fun(filetype: string, lines: string[])
function Hover.format_expandable(frame_id, expr, eval_resp, variables, callback)
    local filetype = vim.bo.filetype
    local lines = {}

    if filetype == "c" or filetype == "cpp" then
        if eval_resp.type and eval_resp.type:match("%*%s*$") then
            if eval_resp.result == "0x0" then
                table.insert(
                    lines,
                    string.format("%s = %s", expr, eval_resp.result)
                )
                goto done
            else
                Hover.eval_expr(frame_id, "*" .. expr)
                return
            end
        else
            table.insert(
                lines,
                string.format("%s = (%s) {", expr, eval_resp.type)
            )
        end
        for _, var in ipairs(variables) do
            if var.variablesReference and var.variablesReference > 0 then
                table.insert(
                    lines,
                    string.format("  .%s = (%s) { ... },", var.name, var.type)
                )
            else
                table.insert(
                    lines,
                    string.format("  .%s = %s,", var.name, var.value or "?")
                )
            end
        end
        table.insert(lines, "}")
    elseif filetype == "python" then
        local ignored_names = {
            ["special variables"] = true,
            ["function variables"] = true,
            ["class variables"] = true,
        }
        local ignored_types = {
            ["method"] = true,
            ["function"] = true,
        }
        table.insert(lines, string.format("%s: %s", expr, eval_resp.type))
        for _, var in ipairs(variables) do
            if ignored_names[var.name] or ignored_types[var.type] then
                goto continue
            end

            if var.variablesReference and var.variablesReference > 0 then
                table.insert(
                    lines,
                    string.format("    %s: %s = ...", var.name, var.type)
                )
            else
                table.insert(
                    lines,
                    string.format(
                        "    %s: %s = %s",
                        var.name,
                        var.type,
                        var.value
                    )
                )
            end
            ::continue::
        end
    else
        filetype = "yaml"
        table.insert(lines, string.format("%s:", expr))
        for _, var in ipairs(variables) do
            if var.variablesReference and var.variablesReference > 0 then
                table.insert(lines, string.format("  %s: ...", var.name))
            else
                table.insert(
                    lines,
                    string.format("  %s: %s", var.name, var.value)
                )
            end
        end
    end

    ::done::
    callback(filetype, lines)
end

---@param frame_id integer
---@param expr string
function Hover.eval_expr(frame_id, expr)
    Hover.session:request("evaluate", {
        expression = expr,
        frameId = frame_id,
        context = "hover",
    }, function(err, resp)
        if err or not resp or not resp.result then
            if err then
                log.warning("Failed to evaluate '%s': %s", expr, err)
            end
            return
        end

        if resp.variablesReference and resp.variablesReference > 0 then
            Hover.session:request("variables", {
                variablesReference = resp.variablesReference,
            }, function(e, r)
                if e or not r or #r.variables <= 0 then
                    log.warning("Failed to evaluate '%s': %s", expr, e)
                    Hover.show_lines(
                        vim.bo.filetype,
                        { string.format("%s = %s", expr, resp.result) }
                    )
                else
                    Hover.format_expandable(
                        frame_id,
                        expr,
                        resp,
                        r.variables,
                        function(filetype, lines)
                            Hover.show_lines(filetype, lines)
                        end
                    )
                end
            end)
        else
            Hover.show_lines(
                vim.bo.filetype,
                { string.format("%s = %s", expr, resp.result) }
            )
        end
    end)
end

function Hover.dap_hover()
    Hover.dap = require("dap")
    Hover.session = Hover.dap.session()
    if not Hover.session then
        return
    end

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

    Hover.session:request(
        "stackTrace",
        { threadId = 1 },
        function(err, stack_resp)
            if err or not stack_resp or not stack_resp.stackFrames[1] then
                return
            end

            local frame_id = stack_resp.stackFrames[1].id
            Hover.eval_expr(frame_id, expr)
        end
    )
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
            "<Leader>do",
            function()
                require("dap").up()
            end,
        },
        {
            "<Leader>di",
            function()
                require("dap").down()
            end,
        },
        {
            "<Leader>dk",
            Hover.dap_hover,
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

        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap" },
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
