-- spec:
-- https://github.com/bmewburn/intelephense-docs/blob/master/installation.md
-- https://github.com/bmewburn/vscode-intelephense/blob/master/package.json

local utils = require("ow.utils")

return {
    enable = true,
    dependencies = {
        "npm",
    },
    mason = { "intelephense", dependencies = { {"phpcs", "pretty-php" } } },
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
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "pretty-php",
                        "--psr12",
                        "--enable=align-comments",
                        "-qq",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
        {
            mode = "x",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "pretty-php",
                        "--psr12",
                        "--enable=align-comments",
                        "-qq",
                        "-",
                    },
                    output = "stdout",
                })
            end,
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
                    enable = false,
                },
            },
        },
    },
}
