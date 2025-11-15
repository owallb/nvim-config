local lsp = require("lsp")
local util = require("util")

local lua_library_paths = {
    vim.env.VIMRUNTIME,
}
for _, plugin in ipairs(require("lazy").plugins()) do
    table.insert(lua_library_paths, plugin.dir)
end

---@type vim.lsp.Config
return {
    settings = {
        Lua = {
            completion = { showWord = "Disable" },
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
                pathStrict = true,
            },
            workspace = {
                library = lua_library_paths,
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
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        vim.keymap.set("n", "<leader>lf", function()
            util.format({
                buf = bufnr,
                cmd = {
                    "stylua",
                    "--stdin-filepath",
                    "%file%",
                    "-",
                },
                output = "stdout",
                auto_indent = true,
            })
        end, { buffer = bufnr })

        vim.keymap.set("x", "<leader>lf", function()
            util.format({
                buf = bufnr,
                cmd = {
                    "stylua",
                    "--range-start",
                    "%byte_start%",
                    "--range-end",
                    "%byte_end%",
                    "--stdin-filepath",
                    "%file%",
                    "-",
                },
                output = "stdout",
            })
        end, { buffer = bufnr })
    end,
}
