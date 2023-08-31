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

-- Conservative style of the standard Visual Studio
-- with reduced number of colors
-- vim.g.codedark_conservative = 1
-- vim.g.vscode_style = "dark"
-- vim.g.vscode_transparency = 0
-- vim.g.vscode_italic_comment = 1
-- vim.g.vscode_disable_nvimtree_bg = true
-- vim.fn.execute("colorscheme vscode")

-- local c = require('vscode.colors')
require('vscode').setup({
    style = 'dark',

    -- Enable transparent background
    transparent = false,

    -- Enable italic comment
    italic_comments = false,

    -- Disable nvim-tree background color
    disable_nvimtree_bg = false,

    -- Override colors (see ./lua/vscode/colors.lua)
    -- color_overrides = {
    --     vscLineNumber = '#FFFFFF',
    -- },

    -- Override highlight groups (see ./lua/vscode/theme.lua)
    group_overrides = {
        -- this supports the same val table as vim.api.nvim_set_hl
        -- use colors from this colorscheme by requiring vscode.colors!
        -- Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
    }
})

require('vscode').load()