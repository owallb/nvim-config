-- https://github.com/igorlfs/nvim-dap-view

---@type LazyPluginSpec
return {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
        {
            "<Leader>du",
            function()
                require("dapui").toggle()
            end,
        },
        {
            "<Leader>de",
            function()
                require("dapui").eval()
            end,
        },
        {
            "<Leader>dw",
            function()
                require("dapui").elements.watches.add(vim.fn.expand("<cexpr>"))
            end,
        },
    },
    opts = {
        controls = {
            element = "repl",
            enabled = false,
        },
        expand_lines = true,
        floating = {
            border = "single",
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
        force_buffers = true,
        icons = {
            collapsed = "+",
            current_frame = "*",
            expanded = "-",
        },
        layouts = {
            {
                elements = {
                    {
                        id = "scopes",
                        size = 0.25,
                    },
                    {
                        id = "breakpoints",
                        size = 0.25,
                    },
                    {
                        id = "stacks",
                        size = 0.25,
                    },
                    {
                        id = "watches",
                        size = 0.25,
                    },
                },
                position = "right",
                size = 50,
            },
            {
                elements = {
                    {
                        id = "repl",
                    },
                },
                position = "bottom",
                size = 15,
            },
        },
        mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>", "<Tab>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t",
        },
        render = {
            indent = 1,
            max_value_lines = 100,
        },
    },
}
