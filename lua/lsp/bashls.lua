return {
    enabled = true,
    dependencies = {
        "npm",
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
