local utils = require("utils")

---@type ServerConfig
return {
    enable = true,
    mason = { "pyright" },
    linters = {
        {
            cmd = {
                "flake8",
                "--max-line-length=100",
                "--max-doc-length=100",
                "--format",
                "%(row)d,%(col)d,%(code).1s: %(text)s",
                "-",
            },
            stdin = true,
            stdout = true,
            pattern = "^(%d+),(%d+),(%w): (.*)",
            groups = { "lnum", "col", "severity", "message" },
            source = "flake8",
            severity_map = {
                E = vim.diagnostic.severity.ERROR,
                W = vim.diagnostic.severity.WARN,
                B = vim.diagnostic.severity.HINT,
                F = vim.diagnostic.severity.HINT,
                D = vim.diagnostic.severity.INFO,
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
                        "black",
                        "--line-length",
                        "100",
                        "--stdin-filename",
                        "%filename%",
                        "--quiet",
                        "-",
                    },
                    stdin = true,
                    stdout = true,
                })
                utils.format({
                    cmd = {
                        "isort",
                        "--quiet",
                        "-",
                    },
                    stdin = true,
                    stdout = true,
                })
            end,
        },
        {
            mode = "x",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "black",
                        "--line-length",
                        "100",
                        "--stdin-filename",
                        "%filename%",
                        "--quiet",
                        "--line-ranges=%row_start%-%row_end%",
                        "-",
                    },
                    stdin = true,
                    stdout = true,
                })
            end,
        },
    },
    lspconfig = {
        filetypes = { "python" },
        cmd = { "pyright-langserver", "--stdio" },
        single_file_support = true,
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                },
            },
        },
    },
}
