-- https://github.com/mfussenegger/nvim-dap

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
            "<F1>",
            function()
                require("dap.ui.widgets").hover()
            end,
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
            "<F6>",
            function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes)
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

        -- https://sourceware.org/gdb/current/onlinedocs/gdb#Debugger-Adapter-Protocol
        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = {
                "--interpreter=dap",
                "--eval-command",
                "set print pretty on",
                "--eval-command",
                "set startup-with-shell off",
            },
        }

        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = function()
                    return vim.fn.input(
                        "Path to executable: ",
                        vim.fn.getcwd() .. "/",
                        "file"
                    )
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }
    end,
}
