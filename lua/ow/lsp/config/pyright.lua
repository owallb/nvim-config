---@type ServerConfig
return {
    mason = { "pyright" },
    lspconfig = {
        filetypes = {
            "python",
        },
        cmd = { "pyright-langserver", "--stdio" },
        single_file_support = true,
        -- https://microsoft.github.io/pyright/#/settings
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
                disableLanguageServices = true,
            },
        },
    },
}

