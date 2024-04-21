-- https://github.com/sindrets/diffview.nvim

---@type LazyPluginSpec
return {
    "sindrets/diffview.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>gg", vim.cmd.DiffviewOpen, mode = "n", remap = true },
    },
    config = function()
        local actions = require("diffview.actions")
        require("diffview").setup({
            enhanced_diff_hl = true,
            view = {
                default = {
                    layout = "diff2_horizontal",
                    winbar_info = true,
                },
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                    winbar_info = true,
                },
                file_history = {
                    layout = "diff2_horizontal",
                    winbar_info = true,
                },
            },
            default_args = {
                DiffviewOpen = { "--imply-local" },
            },
            keymaps = {
                file_panel = {
                    ["<cr>"] = false,
                    {
                        "n",
                        "<CR>",
                        function()
                            actions.select_entry()
                            vim.cmd.wincmd("l")
                        end,
                        { desc = "Open the current file in diffview" },
                    },
                    {
                        "n",
                        "s",
                        actions.toggle_stage_entry,
                        { desc = "Stage / unstage the selected entry" },
                    },
                    {
                        "n",
                        "u",
                        actions.toggle_stage_entry,
                        { desc = "Stage / unstage the selected entry" },
                    },
                    {
                        "n",
                        "cc",
                        function()
                            vim.cmd.G("commit")
                            vim.cmd.wincmd("J")
                        end,
                        { desc = "Commit staged changes" },
                    },
                    {
                        "n",
                        "ca",
                        function()
                            vim.cmd.G("commit --amend")
                            vim.cmd.wincmd("J")
                        end,
                        { desc = "Amend the last commit" },
                    },
                },
            },
        })
    end,
}
