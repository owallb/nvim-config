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

require("nightfox").setup({
    options = {
        -- Compiled file's destination location
        compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        compile_file_suffix = "_compiled", -- Compiled file suffix
        transparent = false,               -- Disable setting background
        terminal_colors = true,            -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
        dim_inactive = false,              -- Non focused panes set to alternative background
        styles = {                         -- Style to be applied to different syntax groups
            comments = "NONE",             -- Value is any valid attr-list value `:help attr-list`
            functions = "NONE",
            keywords = "NONE",
            numbers = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
        },
        inverse = { -- Inverse highlight for different types
            match_paren = false,
            visual = false,
            search = false,
        },
        modules = { -- List of various plugins and additional options
            cmp = true,
            diagnostic = {
                enable = true,
                background = true,
            },
            gitsigns = true,
            native_lsp = true,
            nvimtree = true,
            telescope = true,
            treesitter = true,
        },
    },
    groups = {
        all = {
            -- By default nightfox links some groups together. `CursorColumn` is one of these groups. When overriding
            -- Make sure `link` is cleared to `""` so that the link will be removed.
            -- see https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/group/editor.lua
            Normal = { bg = "palette.bg0", link = "", },
            NormalNC = { bg = "palette.bg0", link = "", },
            NormalFloat = { bg = "palette.bg1", link = "", },
            CursorLine = { bg = "palette.bg1", link = "", },
            StatusLine = { bg = "palette.bg1", link = "", },
            StatusLineNC = { bg = "palette.bg1", link = "", },
        },
    },
})

vim.cmd("colorscheme nightfox")
