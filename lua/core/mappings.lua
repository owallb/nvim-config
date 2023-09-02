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

--- Window mappings ---
vim.keymap.set("n", "<A-h>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<A-j>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<A-k>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<A-l>", ":wincmd l<CR>", opts)
-- Open new window in horizontal split
vim.keymap.set("n", "<C-w>h", ":new<CR>", opts)
-- Open new window in vertical split
vim.keymap.set("n", "<C-w>v", ":vnew<CR>", opts)
-- Open new window in horizontal split at bottom
vim.keymap.set("n", "<C-w><leader>", ":bo new<CR>", opts)
-- Close buffer and window
vim.keymap.set("n", "<C-w>q", ":bd<CR>", opts)

--- Buffer mappings ---
-- Navigate up/down half a screen
vim.keymap.set({ "n", "v", }, "<C-j>", "<C-d>", opts)
vim.keymap.set({ "n", "v", }, "<C-k>", "<C-u>", opts)
-- Center cursorline
vim.keymap.set("n", "<C-Space>", "zz", opts)
-- Save buffer
vim.keymap.set("n", "<C-s>", ":w<CR>", opts)
-- Cycle buffers
vim.keymap.set("n", "<C-End>", ":BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<C-Home>", ":BufferLineCyclePrev<CR>", opts)
-- Close buffer without closing window
vim.keymap.set("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>", opts)

--- General mappings ---
-- Remap some swedish keys for easier use
vim.keymap.set("n", "ö", "}", { remap = true, })
vim.keymap.set("v", "ö", "}", { remap = true, })
vim.keymap.set("n", "ä", "{", { remap = true, })
vim.keymap.set("v", "ä", "{", { remap = true, })
vim.keymap.set("n", ",", "]", { remap = true, })
vim.keymap.set("n", ".", "[", { remap = true, })
-- yank/put using named register
vim.keymap.set("n", "<leader>y", '"0y', opts)
vim.keymap.set("v", "<leader>y", '"0y', opts)
vim.keymap.set("n", "<leader>p", '"0p', opts)
vim.keymap.set("v", "<leader>p", '"0p', opts)
-- Allow exiting insert mode in terminal by hitting <ESC>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
-- Navigate forward/backwards
vim.keymap.set("n", "<C-l>", "<C-i>", opts)
vim.keymap.set("n", "<C-h>", "<C-o>", opts)
-- Use :diffput/get instead of normal one to allow staging visual selection
vim.keymap.set("n", "<leader>dp", "&diff ? ':diffput<CR>' : '<leader>dp'", opts_expr)
vim.keymap.set("v", "<leader>dp", "&diff ? ':diffput<CR>' : '<leader>dp'", opts_expr)
vim.keymap.set("n", "<leader>do", "&diff ? ':diffget<CR>' : '<leader>do'", opts_expr)
vim.keymap.set("v", "<leader>do", "&diff ? ':diffget<CR>' : '<leader>do'", opts_expr)

-- Remove default mappings
vim.keymap.set("", "<C-LeftMouse>", "")
vim.keymap.set("", "q", "")
