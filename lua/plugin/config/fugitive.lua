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

-- https://github.com/tpope/vim-fugitive

local function git_status_tab()
    vim.fn.execute("tabnew")
    vim.fn.execute("leftabove vertical G")
    vim.fn.execute("vertical resize 60 | set wfw")
end

vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { remap = false, })
vim.keymap.set("n", "<leader>gg", git_status_tab, { silent = true, remap = false, })
vim.keymap.set("n", "<leader>gc", ":G commit<CR>", { remap = false, })
