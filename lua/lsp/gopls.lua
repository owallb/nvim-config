-- spec: https://rust-analyzer.github.io/manual.html#configuration

return {
    enabled = true,
    lspconfig = {
        filetypes = {
            "go",
            "gomod",
            "gowork",
            "gotmpl",
        },
        cmd = { "gopls", },
        single_file_support = true,
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true,
            },
        },
    },
}
