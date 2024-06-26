-- https://github.com/is0n/fm-nvim

---@type LazyPluginSpec
return {
    "is0n/fm-nvim",
    keys = {
        {
            "<leader>fe",
            function()
                local file = vim.fn.expand("%:p")
                if file ~= "" then vim.cmd.Lf(file) else vim.cmd.Lf() end
            end,
            mode = "n",
        },
    },
    opts = {
        -- UI Options
        ui = {
            float = {
                -- Floating window border (see ':h nvim_open_win')
                border = "single",
            },
        },

        -- Terminal commands used w/ file manager (have to be in your $PATH)
        cmds = {
            nnn_cmd = "n",
        },
    },
}
