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

-- spec: https://luals.github.io/wiki/settings/

return {
    enabled = true,
    lspconfig = {
        filetypes = {
            "lua",
        },
        cmd = { "lua-language-server", },
        single_file_support = true,
        settings = {
            Lua = {
                completion = {
                    showWord = "Disable",
                },
                diagnostics = {
                    disable = { "missing-fields", },
                },
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                        "?/lua/?.lua",
                        "?/lua/?/init.lua",
                    },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                        vim.fn.stdpath("data") .. "/lazy",
                    },
                    checkThirdParty = false,
                },
                hint = {
                    enable = false,
                    arrayIndex = "Disable",
                    await = true,
                    paramName = "All",
                    paramType = true,
                    semicolon = "Disable",
                    setType = true,
                },
                telemetry = { enable = false, },
            },
        },
    },
}
