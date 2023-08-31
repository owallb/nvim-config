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

local utils = require 'utils'

local hl_CustomHeader
local head_cache
--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
    return function(str)
        local win_width = vim.fn.winwidth(0)
        if hide_width and win_width < hide_width then
            return ''
        elseif trunc_width and trunc_len and win_width < trunc_width and #str >
            trunc_len then
            return str:sub(1, trunc_len) .. (no_ellipsis and '' or '...')
        end
        return str
    end
end

--- @param trunc_len number truncates component to trunc_len number of chars
--- @param no_ellipsis boolean whether to disable adding '...' at start before truncation
--- return function that can format the component accordingly
local function l_trunc(trunc_len, no_ellipsis)
    return function(str)
        if #str > trunc_len then
            if no_ellipsis then
                return str:sub(#str - trunc_len)
            else
                return '...' .. str:sub(#str - trunc_len + 3)
            end
        else
            return str
        end
    end
end

--- @param trunc_len number truncates component to trunc_len number of chars
--- @param no_ellipsis boolean whether to disable adding '...' at start before truncation
--- return function that can format the component accordingly
local function r_trunc(trunc_len, no_ellipsis)
    return function(str)
        if #str > trunc_len then
            if no_ellipsis then
                return str:sub(1, trunc_len)
            elseif #str < trunc_len then
                return str
            else
                return str:sub(1, trunc_len - 3) ..
                    (no_ellipsis and '' or '...')
            end
        end
        return str
    end
end

local function short_path(len)
    return function(str)
        if #str > len then return vim.fn.pathshorten(str, 1) end
        return str
    end
end

local function header()
    if hl_CustomHeader == nil then
        local header_hl = require('utils').get_hl('NvimTreeNormal')
        if header_hl ~= nil then
            hl_CustomHeader = 'gui=bold guifg=' .. header_hl.foreground ..
                ' guibg=' .. header_hl.background
            vim.api.nvim_command('hi CustomHeader ' .. hl_CustomHeader)
        end
    end
    -- local header = short_path(40)(vim.fn.getcwd())
    -- NOTE: Decided not to use this. Probably doesn't work.
    local gitdir = vim.fn.FugitiveExtractGitDir(vim.fn.getcwd())
    local text = ''
    if gitdir == '' then
        text = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
    else
        text = vim.fn.fnamemodify(gitdir, ':~:h')
        -- text = vim.fn.fnamemodify(vim.fn.FugitiveWorkTree(), ':~')
        -- local branch = r_trunc(15, false)(vim.fn.FugitiveHead())
        local head = vim.fn.FugitiveHead(8, gitdir)
        if head == '' then
            if head_cache[gitdir] ~= nil then
                head = head_cache[gitdir]
            else
                local f = io.open(gitdir, 'r')
                if f then
                    io.input(f)
                    local line = io.read('*l')
                    local head = line:gsub(
                        'ref: /refs/(heads/|remotes/|tags/)', ''
                    )
                    head_cache[gitdir] = head
                end
            end
        end
        if head ~= '' then text = text .. '  ' .. head end
    end

    -- return l_trunc(40-2, false)(short_path(40-2)(text))
    return l_trunc(40 - 2, false)(text)
end

require('bufferline').setup(
    {
        options = {
            mode = 'buffers',
            numbers = function(ordinal, id, lower, raise) return '' end,
            close_command = 'bdelete %d', -- can be a string | function, see "Mouse actions"
            right_mouse_command = 'bdelete %d', -- can be a string | function, see "Mouse actions"
            left_mouse_command = 'buffer %d', -- can be a string | function, see "Mouse actions"
            middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
            indicator = {
                icon = '▎', -- this should be omitted if indicator style is not 'icon'
                style = 'icon'
            },
            buffer_close_icon = '',
            modified_icon = '●',
            close_icon = '',
            left_trunc_marker = '',
            right_trunc_marker = '',
            --- name_formatter can be used to change the buffer's label in the bufferline.
            --- Please note some names can/will break the
            --- bufferline so use this at your discretion knowing that it has
            --- some limitations that will *NOT* be fixed.
            name_formatter = function(buf) -- buf contains:
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
            diagnostics = 'nvim_lsp',
            diagnostics_update_in_insert = false,
            diagnostics_indicator = function(count, _, _, _)
                return '(' .. count .. ')'
            end,
            -- NOTE: this will be called a lot so don't do any heavy processing here
            custom_filter = function(buf, _)
                local disabled_ft = { 'NvimTree', 'fugitive' }

                if utils.has_value(disabled_ft, vim.bo[buf].filetype) then
                    return false
                end

                return true
            end,
            offsets = {
                {
                    filetype = 'NvimTree',
                    text = 'File Explorer', -- header,
                    text_align = 'center',
                    seperator = true
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                },
                {
                    filetype = 'fugitive',
                    text = 'Fugitive', -- header,
                    text_align = 'center',
                    seperator = true
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                },
                {
                    filetype = 'aerial',
                    text = 'Aerial', -- header,
                    text_align = 'center',
                    seperator = true
                    -- padding = 1,
                    -- highlight = "CustomHeader",
                }
            },
            color_icons = true, -- whether or not to add the filetype icon highlights
            show_buffer_icons = true, -- disable filetype icons for buffers
            show_buffer_close_icons = false,
            show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
            show_close_icon = false,
            show_tab_indicators = true,
            persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
            -- can also be a table containing 2 custom separators
            -- [focused and unfocused]. eg: { '|', '|' }
            separator_style = 'thin', -- | "thick" | "thin" | { 'any', 'any' },
            enforce_regular_tabs = true,
            always_show_bufferline = true,
            hover = { enabled = true, delay = 200, reveal = { 'close' } },
            sort_by = 'id'
        }
    }
)
