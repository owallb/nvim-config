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

-- https://github.com/akinsho/bufferline.nvim

--- Define what filetypes should be ignored by bufferline.
--- Filetypes not listed are enabled by default.
local ft_map = {
    NvimTree = false,
    fugitive = false,
}

require("bufferline").setup(
    {
        options = {
            diagnostics = "nvim_lsp",
            diagnostics_update_in_insert = false,
            custom_filter = function (buf, _)
                local buf_ft = vim.bo[buf].filetype

                if ft_map[buf_ft] == nil then
                    ft_map[buf_ft] = true -- enable by default
                end

                return ft_map[buf_ft]
            end,
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    text_align = "center",
                    seperator = true,
                },
                {
                    filetype = "fugitive",
                    text = "Fugitive",
                    text_align = "center",
                    seperator = true,
                },
                {
                    filetype = "aerial",
                    text = "Aerial",
                    text_align = "center",
                    seperator = true,
                },
            },
            sort_by = "id",
        },
    }
)
