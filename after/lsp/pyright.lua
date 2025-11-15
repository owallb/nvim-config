local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = lsp.on_attach,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "strict",
                stubPath = "stubs",
            },
        },
        pyright = {
            disableLanguageServices = false,
        },
    },
}
