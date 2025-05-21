---@type ServerConfig
return {
    mason = { "jedi-language-server" },
    lspconfig = {
        filetypes = {
            "python",
        },
        cmd = { "jedi-language-server" },
        single_file_support = true,
        init_options = {
            completion = {
                disableSnippets = true,
            },
            diagnostics = {
                enable = true,
            },
        },
    },
}

