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

-- https://github.com/nvim-lualine/lualine.nvim

require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "", },
        section_separators = { left = "", right = "", },
        disabled_filetypes = { "NvimTree", "fugitive", },
        always_divide_middle = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = {},
        lualine_b = { "mode", },
        lualine_c = { { "filename", path = 1, }, "diff", { "diagnostics", sources = { "nvim_lsp", }, }, },
        lualine_x = { "filetype", "encoding", "fileformat", "progress", },
        lualine_y = { "location", },
        lualine_z = {},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename", },
        lualine_x = { "location", },
        lualine_y = {},
        lualine_z = {},
    },
})
