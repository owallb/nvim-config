local utils = require("utils")

---@type ServerConfig
return {
    enable = false,
    dependencies = { "python3" },
    mason = { "jedi-language-server" },
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
                    output = "stdout",
                })
                utils.format({
                    cmd = {
                        "isort",
                        "--quiet",
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
                        "black",
                        "--line-length",
                        "100",
                        "--stdin-filename",
                        "%filename%",
                        "--quiet",
                        "--line-ranges=%row_start%-%row_end%",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
    },
    lspconfig = {
        filetypes = {
            "python",
        },
        cmd = { "jedi-language-server" },
        single_file_support = true,
        -- For more info see:
        -- - https://github.com/pappasam/jedi-language-server#configuration
        -- - https://github.com/pappasam/coc-jedi#configuration (good descriptions)
        init_options = {
            -- Built-in diagnostics seem to be very basic,
            -- to the point where you are wondering if it's even active.
            -- Will use flake8 together with diagnosticls for added linting
            diagnostics = {
                -- Enables (or disables) diagnostics provided by Jedi
                -- type: boolean
                -- default: true
                enable = true,
            },
            -- The preferred MarkupKind for all jedi-language-server messages that take MarkupContent.
            -- type: string
            -- accepted values: "markdown", "plaintext"
            -- If omitted, jedi-language-server defaults to the client-preferred configuration.
            -- If there is no client-preferred configuration, jedi language server users "plaintext".
            -- markupKindPreferred = "markdown",
            workspace = {
                symbols = {
                    -- Performance optimization that sets names of folders that are ignored for workspace/symbols.
                    -- type: string[]
                    -- default: { ".nox", ".tox", ".venv", "__pycache__", "venv" }
                    -- If you manually set this option, it overrides the default.
                    -- Setting it to an empty array will result in no ignored folders.
                    ignoreFolders = {
                        ".nox",
                        ".tox",
                        ".venv",
                        "__pycache__",
                        "venv",
                        "artifacts",
                        "config",
                        ".vscode",
                        ".pytest_cache",
                        "build",
                        "scripts",
                        "incoax_tests.egg-info",
                        "node_modules",
                    },
                },
            },
        },
    },
}
