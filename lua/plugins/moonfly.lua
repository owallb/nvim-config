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

-- https://github.com/bluz71/vim-moonfly-colors

local function setup()
    vim.g.moonflyNormalFloat = true
    vim.g.moonflyCursorColor = true
    vim.g.moonflyWinSeparator = 2

    local custom_highlight = vim.api.nvim_create_augroup("CustomMoonflyHighlight", {})
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "moonfly",
        callback = function ()
            vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#364143" })
            vim.api.nvim_set_hl(0, "DiffText", { bg = "#3e4b6b" })
            vim.api.nvim_set_hl(0, "DiffChange", { bg = "#25293c" })
            vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#443244" })
        end,
        group = custom_highlight,
    })

    vim.cmd.colorscheme("moonfly")
end

return setup
