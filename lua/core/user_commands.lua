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

vim.api.nvim_create_user_command(
    "Update",
    function (_)
        require("lazy").update()
        vim.fn.execute(":TSUpdateSync")
        vim.fn.execute(":Neorg sync-parsers")
        vim.fn.execute(":MasonUpdateAll")
    end,
    {
        desc = "Update lazy plugins, treesitter parsers and mason language servers",
        force = false,
    }
)
