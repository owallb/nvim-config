return {
    enable = true,
    dependencies = {
        "npm",
    },
    mason = {
        name = "bash-language-server",
        -- version = "",
    },
    lspconfig = {
        filetypes = {
            "sh",
            "bash",
            "zsh",
        },
        cmd = { "bash-language-server", "start", },
        single_file_support = true,
    },
}
