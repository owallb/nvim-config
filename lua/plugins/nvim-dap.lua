-- https://github.com/mfussenegger/nvim-dap
local hover = require("dap.hover")
local log = require("log")

---@type LazyPluginSpec
return {
    "mfussenegger/nvim-dap",
    lazy = false,
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
            "<PageUp>",
            function()
                require("dap").up()
            end,
        },
        {
            "<PageDown>",
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
