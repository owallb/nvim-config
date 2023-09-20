--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-- https://github.com/sindrets/diffview.nvim

local actions = require("diffview.actions")

require("diffview").setup({
    enhanced_diff_hl = true,
    view = {
        default = {
            layout = "diff3_mixed",
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
        DiffviewOpen = { "--imply-local", },
    },
    keymaps = {
        file_panel = {
            {
                "n",
                "<CR>",
                function()
                    vim.fn.execute("wincmd l")
                    actions.select_entry()
                end,
                { desc = "Focus the diff for the selected entry", },
            },
            {
                "n",
                "s",
                actions.toggle_stage_entry,
                { desc = "Stage / unstage the selected entry", },
            },
            {
                "n",
                "u",
                actions.toggle_stage_entry,
                { desc = "Stage / unstage the selected entry", },
            },
            {
                "n",
                "cc",
                ":G commit | wincmd J<CR>",
                { desc = "Commit staged changes", },
            },
            {
                "n",
                "ca",
                ":G commit --amend | wincmd J<CR>",
                { desc = "Amend the last commit", },
            },
        },
    },
})

local opts = { silent = true, remap = false, }
vim.keymap.set("n", "<leader>gg", ":DiffviewOpen<CR>", opts)
