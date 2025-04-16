-- spec: https://luals.github.io/wiki/settings/
local utils = require("ow.utils")

---@type ServerConfig
return {
    enable = true,
    dependencies = { "cargo" },
    mason = {
        "lua-language-server",
        post_install = { { cmd = { "cargo", "install", "stylua", "--features", "lua54" } } },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = { "stylua", "-" },
                    output = "stdout",
                })
            end,
        },
        {
            mode = "x",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "stylua",
                        "-",
                        "--range-start",
                        "%byte_start%",
                        "--range-end",
                        "%byte_end%",
                    },
                    output = "stdout",
                })
            end,
        },
    },
    lspconfig = {
        filetypes = { "lua" },
        cmd = { "lua-language-server" },
        single_file_support = true,
        settings = {
            Lua = {
                completion = { showWord = "Disable" },
                diagnostics = {
                    -- disable = { "missing-fields" },
                },
                runtime = {
                    version = "LuaJIT",
                    path = {
                        -- "?.lua",
                        "?.lua",
                        "?/init.lua",
                        -- "?.lua",
                        -- "lua/?.lua",
                        -- "lua/?/init.lua",
                        -- "?/lua/?.lua",
                        -- "?/lua/?/init.lua",
                    },
                    -- pathStrict = true,
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                        "~/repos/awesome-code-doc",
                        "/usr/share/awesome/lib",
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
                telemetry = { enable = false },
            },
        },
    },
}
