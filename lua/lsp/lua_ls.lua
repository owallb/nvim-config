-- spec: https://luals.github.io/wiki/settings/

return {
    enable = true,
    mason = {
        name = "lua-language-server",
        -- version = "",
    },
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
