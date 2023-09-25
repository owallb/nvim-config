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

-- https://github.com/lewis6991/gitsigns.nvim

local function setup()
    require("gitsigns").setup({
        on_attach = function (bufnr)
            local gs = package.loaded.gitsigns
            vim.keymap.set("n", "<leader>gv", gs.select_hunk, { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk,
                { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, })
            vim.keymap.set(
                "x",
                "<leader>gr",
                ":Gitsigns reset_hunk<CR>",
                { buffer = bufnr, }
            )
            vim.keymap.set("n", "<leader>g?", gs.preview_hunk,
                { buffer = bufnr, })
            vim.keymap.set(
                "n",
                "<leader>gb",
                function ()
                    gs.blame_line { full = true, ignore_whitespace = true, }
                end,
                { buffer = bufnr, })
        end,
        signs = {
            untracked = { text = "│", },
        },
    })
end

return setup
