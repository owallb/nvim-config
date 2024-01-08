-- spec: https://github.com/bmewburn/intelephense-docs/blob/master/installation.md

return {
    enabled = true,
    dependencies = {
        "npm",
    },
    root_pattern = {
        "composer.json",
        "composer.lock",
        "vendor",
    },
    lspconfig = {
        filetypes = {
            "php",
        },
        cmd = { "intelephense", "--stdio", },
        single_file_support = true,
        settings = {
            intelephense = {
                environment = {
                    phpVersion = "7.4",
                },
                format = {
                    enable = false,
                    braces = "psr12",
                },
            },
        },
    },
}
