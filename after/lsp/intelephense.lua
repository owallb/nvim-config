local Linter = require("linter")
local lsp = require("lsp")
local util = require("util")

---@type vim.lsp.Config
return {
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
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        Linter.add(bufnr, {
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
            groups = { "lnum", "col", "severity", "message", "code" },
            source = "phpcs",
            severity_map = {
                error = vim.diagnostic.severity.ERROR,
                warning = vim.diagnostic.severity.WARN,
            },
            zero_idx_col = true,
            zero_idx_lnum = true,
        })

        vim.keymap.set("n", "<leader>lf", function()
            vim.lsp.buf.format()
            util.format({
                buf = bufnr,
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
        end, { buffer = bufnr })
    end,
}
