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

-- https://github.com/folke/noice.nvim

require("noice").setup({
    cmdline = {
        enabled = false,
    },
    messages = {
        enabled = false,
    },
    popupmenu = {
        enabled = false,
    },
    notify = {
        enabled = false,
    },
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
        hover = {
            enabled = true,
            silent = true,
        },
        signature = {
            enabled = true,
        },
        message = {
            false,
        },
    },
})

-- using notify directly instead
-- vim.notify = require("noice").notify
