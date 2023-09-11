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

-- https://github.com/nvim-tree/nvim-tree.lua

require("nvim-tree").setup({
    sync_root_with_cwd = true,
    view = {
        width = 40,
        preserve_window_proportions = true,
    },
    renderer = {
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        indent_markers = {
            enable = true,
        },
        icons = {
            git_placement = "after",
            show = {
                folder_arrow = true,
            },
        },
    },
    update_focused_file = {
        enable = true,
        update_root = true,
        ignore_list = {
            "help",
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = false,
    },
    actions = {
        change_dir = {
            enable = false,
        },
        open_file = {
            resize_window = true,
        },
    },
    filters = {
        custom = { "^\\.git$", },
    },
})

local opts = { remap = false, silent = true, }
vim.keymap.set("n", "<leader>tt", function () require("nvim-tree.api").tree.toggle() end, opts)
