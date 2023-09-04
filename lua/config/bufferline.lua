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
            mode = "buffers",
            numbers = function (ordinal, id, lower, raise) return "" end,
            close_command = "bdelete %d", -- can be a string | function, see "Mouse actions"
            right_mouse_command = "bdelete %d", -- can be a string | function, see "Mouse actions"
            left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
            middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
            indicator = {
                icon = "▎", -- this should be omitted if indicator style is not 'icon'
                style = "icon",
            },
            buffer_close_icon = "",
            modified_icon = "●",
            close_icon = "",
            left_trunc_marker = "",
            right_trunc_marker = "",
            --- name_formatter can be used to change the buffer's label in the bufferline.
            --- Please note some names can/will break the
            --- bufferline so use this at your discretion knowing that it has
            --- some limitations that will *NOT* be fixed.
            name_formatter = function (buf) -- buf contains:
                -- name                | str        | the basename of the active file
                -- path                | str        | the full path of the active file
                -- bufnr (buffer only) | int        | the number of the active buffer
                -- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
                -- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
                return buf.name
            end,
            max_name_length = 18,
            max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
            truncate_names = true,
            tab_size = 18,
            diagnostics = "nvim_lsp",
            diagnostics_update_in_insert = false,
            diagnostics_indicator = function (count, _, _, _)
                return "(" .. count .. ")"
            end,
            -- NOTE: this will be called a lot so don't do any heavy processing here
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
                    text = "File Explorer", -- header,
                    text_align = "center",
                    seperator = true,
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                },
                {
                    filetype = "fugitive",
                    text = "Fugitive", -- header,
                    text_align = "center",
                    seperator = true,
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                },
                {
                    filetype = "aerial",
                    text = "Aerial", -- header,
                    text_align = "center",
                    seperator = true,
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                },
            },
            color_icons = true,              -- whether or not to add the filetype icon highlights
            show_buffer_icons = true,        -- disable filetype icons for buffers
            show_buffer_close_icons = false,
            show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
            show_close_icon = false,
            show_tab_indicators = true,
            persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
            -- can also be a table containing 2 custom separators
            -- [focused and unfocused]. eg: { '|', '|' }
            separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
            enforce_regular_tabs = true,
            always_show_bufferline = true,
            hover = { enabled = true, delay = 200, reveal = { "close", }, },
            sort_by = "id",
        },
    }
)
