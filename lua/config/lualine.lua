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

--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
  return function(str)
    local win_width = vim.fn.winwidth(0)
    if hide_width and win_width < hide_width then return ''
    elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
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
       return (no_ellipsis and '' or '...') .. str:sub(-trunc_len, -1)
    end
    return str
  end
end

--- @param trunc_len number truncates component to trunc_len number of chars
--- @param no_ellipsis boolean whether to disable adding '...' at start before truncation
--- return function that can format the component accordingly
local function r_trunc(trunc_len, no_ellipsis)
  return function(str)
    if #str > trunc_len then
       return str:sub(1, trunc_len) .. (no_ellipsis and '' or '...')
    end
    return str
  end
end

local function short_path(len)
    return function(str)
        if #str > len then
            return vim.fn.pathshorten(str, 1)
        end
        return str
    end
end

local function header()
    local text = short_path(40)(vim.fn.getcwd())
    local branch = r_trunc(15, false)(vim.fn.FugitiveHead())
    if branch ~= '' then
        text = text .. '  ' .. branch
    end
    return text
end

require('lualine').setup ({
    options = {
        icons_enabled = true,
        -- theme = require('config.nightfox_lualine_custom'),
        theme = 'auto',
        -- theme = "catppuccin",
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'NvimTree', 'fugitive' },
        always_divide_middle = true,
        globalstatus = true
    },
    sections = {
        lualine_a = { },
        lualine_b = { 'mode' },
        lualine_c = { { 'filename', path = 1 }, 'diff', {'diagnostics', sources = {'nvim_lsp'}}},
        lualine_x = { 'filetype', 'encoding', 'fileformat', 'progress' },
        lualine_y = { 'location' },
        lualine_z = { }
    },
    inactive_sections = {
        lualine_a = { },
        lualine_b = { },
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = { },
        lualine_z = { }
    },
    -- tabline = {
    --     lualine_a = { { header } },
    --     lualine_b = { {'tabs', mode = 0 } },
    --     lualine_c = { { 'buffers', show_filename_only = true, filetype_names = { TelescopePrompt = 'Telescope', fugitive = 'Fugitive' } } },
    --     lualine_x = {},
    --     lualine_y = {},
    --     lualine_z = {}
    -- },
    extensions = { }
})

