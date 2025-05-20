-- spec:
-- https://github.com/bmewburn/intelephense-docs/blob/master/installation.md
-- https://github.com/bmewburn/vscode-intelephense/blob/master/package.json

local utils = require("ow.utils")

---@type ServerConfig
return {
    enable = true,
    dependencies = {
        "npm",
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
            zero_idx_col = true,
            zero_idx_lnum = true,
        },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                vim.lsp.buf.format()
                utils.format({
                    cmd = {
                        "php-cs-fixer",
                        "fix",
                        "%file%",
                        "--quiet",
                    },
                    output = "in_place",
                    ignore_stderr = true,
                    env = { PHP_CS_FIXER_IGNORE_ENV = "1" },
                })
            end,
        },
    },
    settings_file = ".intelephense.json",
    lspconfig = {
        filetypes = {
            "php",
        },
        cmd = { "intelephense", "--stdio" },
        single_file_support = true,
        settings = {
            intelephense = {
                environment = {
                    phpVersion = "8.4",
                },
                format = {
                    enable = true,
                    braces = "psr12",
                },
            },
        },
    },
}
