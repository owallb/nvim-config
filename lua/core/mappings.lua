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

local opts = { remap = false, silent = true, }
local opts_expr = { remap = false, silent = true, expr = true, }

--- Tab mappings ---
-- vim.keymap.set('n', "tn", ":tabnew <BAR> NvimTreeOpen<CR>", opts)
vim.keymap.set("n", "tn", ":tabnew<CR>", opts)
vim.keymap.set("n", "tq", ":tabclose<CR>", opts)
-- switch tabs with Ctrl+PgUp/Ctrl+PgDwn (default vim mapping)

--- Buffer mappings ---
-- Center cursorline
vim.keymap.set("n", "<leader><leader>", "zz", opts)
-- Save buffer
vim.keymap.set(
    "n", "<C-s>",
    -- workaround for double save messages
    function () vim.api.nvim_command(":silent w") end,
    { remap = false, }
)
-- Cycle buffers
vim.keymap.set("n", "<C-End>", ":BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<C-Home>", ":BufferLineCyclePrev<CR>", opts)

--- General mappings ---
-- yank/put using named register
vim.keymap.set({ "n", "x", }, "<leader>y", '"+y', opts)
vim.keymap.set({ "n", "x", }, "<leader>p", '"+p', opts)
-- Allow exiting insert mode in terminal by hitting <ESC>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
-- Use :diffput/get instead of normal one to allow staging visual selection
vim.keymap.set({ "n", "x", }, "<leader>dp",
    "&diff ? ':diffput<CR>' : '<leader>dp'", opts_expr)
vim.keymap.set({ "n", "x", }, "<leader>do",
    "&diff ? ':diffget<CR>' : '<leader>do'", opts_expr)

-- Remove default mappings
vim.keymap.set("", "<C-LeftMouse>", "")
vim.keymap.set("", "q", "")

-- Remove right-click menu items
vim.cmd.aunmenu({ "PopUp.-1-", })
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse", })

-- Silence some keys
vim.keymap.set({ "n", "v", }, "u", ":silent undo<CR>", { silent = true, })
vim.keymap.set({ "n", "v", }, "<C-r>", ":silent redo<CR>", { silent = true, })
