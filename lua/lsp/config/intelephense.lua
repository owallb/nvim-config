-- spec:
-- https://github.com/bmewburn/intelephense-docs/blob/master/installation.md
-- https://github.com/bmewburn/vscode-intelephense/blob/master/package.json

return {
    enable = true,
    dependencies = {
        "npm",
    },
    root_pattern = {
        "composer.json",
        "composer.lock",
        "vendor",
    },
    mason = { "intelephense", dependencies = { "phpcs" } },
    linters = {
        {
            cmd = {
                "phpcs",
                "--standard=PSR12",
                "--report=emacs",
                "-s",
                "-q",
                "-",
            },
            stdin = true,
            stdout = true,
            pattern = "^.+:(%d+):(%d+): (%w+) %- (.*) %((.*)%)$",
            groups = { "lnum", "col", "severity", "message", "source" },
            source = "phpcs",
            severity_map = {
                error = vim.diagnostic.severity.ERROR,
                warning = vim.diagnostic.severity.WARN,
            },
        },
    },
    lspconfig = {
        filetypes = {
            "php",
        },
        cmd = { "intelephense", "--stdio" },
        single_file_support = true,
        settings = {
            intelephense = {
                environment = {
                    phpVersion = "7.4",
                },
                format = {
                    enable = true,
                },
            },
        },
    },
}
