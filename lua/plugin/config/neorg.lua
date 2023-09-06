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

-- https://github.com/nvim-neorg/neorg

require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.keybinds"] = {
            config = {
                hook = function (keybinds)
                    keybinds.unmap("norg", "n", "<C-Space>")
                    keybinds.remap_event("norg", "n", keybinds.leader .. "tt", "core.qol.todo_items.todo.task_cycle")
                end,
            },
        },
        ["core.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/Documents/notes",
                },
            },
        },
        ["core.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
        ["core.export"] = {},
    },
})
