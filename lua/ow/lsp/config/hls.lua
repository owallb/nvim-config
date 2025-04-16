return {
    enable = true,
    mason = {
        name = "haskell-language-server",
        -- version = "",
    },
    lspconfig = {
        filetypes = { "haskell", "lhaskell", "cabal", },
        cmd = { "haskell-language-server-wrapper", "--lsp", },
        single_file_support = true,
        settings = {
            haskell = {
                cabalFormattingProvider = "cabalfmt",
                formattingProvider = "ormolu",
            },
        },
    },
}
