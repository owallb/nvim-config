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

-- https://github.com/catppuccin/nvim

local catppuccin = require("catppuccin")

catppuccin.setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    no_italic = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        aerial = true,
        indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
        },
        mason = true,
        neogit = true,
        dap = {
            enabled = true,
            enable_ui = true,
        },
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = {},
                hints = {},
                warnings = {},
                information = {},
            },
            underlines = {
                errors = { "underline", },
                hints = { "underline", },
                warnings = { "underline", },
                information = { "underline", },
            },
            inlay_hints = {
                background = true,
            },
        },
        telescope = {
            enabled = true,
        },
        lsp_trouble = true,
    },
})

catppuccin.load()
