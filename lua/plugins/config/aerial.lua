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

-- https://github.com/stevearc/aerial.nvim

require("aerial").setup({
    layout = {
        min_width = 40,
        placement = "edge",
    },
    disable_max_size = 10000000,
    highlight_on_hover = true,
    ignore = {
        unlisted_buffers = true,
    },
    on_attach = function (bufnr)
        -- Toggle the aerial window with <leader>a
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>at", "<cmd>AerialToggle!<CR>", {})
        -- Jump forwards/backwards with '{' and '}'
        vim.api.nvim_buf_set_keymap(bufnr, "n", "{", "<cmd>AerialPrev<CR>", {})
        vim.api.nvim_buf_set_keymap(bufnr, "n", "}", "<cmd>AerialNext<CR>", {})
        -- Jump up the tree with '[[' or ']]'
        vim.api.nvim_buf_set_keymap(bufnr, "n", "[[", "<cmd>AerialPrevUp<CR>", {})
        vim.api.nvim_buf_set_keymap(bufnr, "n", "]]", "<cmd>AerialNextUp<CR>", {})
    end,
    show_guides = true,
})

