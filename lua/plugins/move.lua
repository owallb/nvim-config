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

-- https://github.com/fedepujol/move.nvim

local function setup()
    local opts = { noremap = true, silent = true, }
    vim.keymap.set("n", "<A-j>", function () vim.cmd.MoveLine(1) end, opts)
    vim.keymap.set("n", "<A-k>", function () vim.cmd.MoveLine(-1) end, opts)
    vim.keymap.set("n", "<A-h>", function () vim.cmd.MoveHChar(-1) end, opts)
    vim.keymap.set("n", "<A-l>", function () vim.cmd.MoveHChar(1) end, opts)
    vim.keymap.set("x", "<A-j>", ":MoveBlock(1)<CR>", opts)
    vim.keymap.set("x", "<A-k>", ":MoveBlock(-1)<CR>", opts)
    vim.keymap.set("x", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
    vim.keymap.set("x", "<A-l>", ":MoveHBlock(1)<CR>", opts)
end

return setup
