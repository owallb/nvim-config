local servers = {
    "bashls",
    "clangd",
    "cmake",
    "diagnosticls",
    "groovyls",
    "jedi_language_server",
    "lemminx",
    "lua_ls",
}

local manifest = {}

for _, name in ipairs(servers) do
    manifest[name] = require("lsp.servers." .. name)
end

return manifest
