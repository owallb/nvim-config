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

local module_name = "core.user_commands"
local utils = require("utils")

vim.api.nvim_create_user_command(
    "Update",
    function (_)
        utils.try_require(
            "lazy",
            module_name,
            function (lazy)
                lazy.update()
            end
        )

        utils.try_require(
            "nvim-treesitter.install",
            module_name,
            function (treesitter_install)
                treesitter_install.update({ with_sync = true, })("all")
            end
        )

        utils.try_require(
            "mason-update-all",
            module_name,
            function (mason_update_all)
                mason_update_all.update_all()
            end
        )
    end,
    {
        desc =
        "Update lazy plugins, treesitter parsers and mason language servers",
        force = false,
    }
)
