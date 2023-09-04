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

local function map(bufnr, mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
end

require("gitsigns").setup({
    on_attach = function (bufnr)
        local gs = package.loaded.gitsigns
        map(bufnr, "n", "<leader>gv", gs.select_hunk)
        map(bufnr, { "n", "v", }, "<leader>gr", ":Gitsigns reset_hunk<CR>") -- gs.reset_hunk() doesn't work with selected lines
        map(bufnr, "n", "<leader>g?", gs.preview_hunk)
        map(bufnr, "n", "<leader>gb", function ()
            gs.blame_line { full = true, }
        end)
    end,
    signs = {
        untracked = { text = "│", },
    },
})
