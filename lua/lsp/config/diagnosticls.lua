-- For more info see:
-- https://github.com/iamcco/diagnostic-languageserver

-- More examples at:
-- https://github.com/iamcco/coc-diagnostic/blob/master/src/config.ts

return {
    enable = false,
    dependencies = {
        "npm",
    },
    mason = {
        -- TODO: figure out if possible to install required formatters/linters
        --       in this language server automatically through mason
        name = "diagnostic-languageserver",
        -- version = "",
    },
    lspconfig = {
        filetypes = {
            -- "python",
            "sh",
            "bash",
            "zsh",
            "php",
        },
        cmd = { "diagnostic-languageserver", "--stdio", },
        single_file_support = true,
        init_options = {
            filetypes = {
                -- python = "flake8",
                php = "phpcs",
            },
            linters = {
                -- some help from this:
                -- https://github.com/creativenull/diagnosticls-configs-nvim/blob/main/lua/diagnosticls-configs/linters/flake8.lua
                flake8 = {
                    command = "flake8",
                    args = {
                        "--max-line-length=100",
                        "--max-doc-length=100",
                        "--format",
                        "%(row)d,%(col)d,%(code).1s,%(code)s: %(text)s",
                        "-",
                    },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    debounce = 100,
                    offsetLine = 0,
                    offsetColumn = 0,
                    sourceName = "flake8",
                    formatLines = 1,
                    formatPattern = {
                        [[^(\d+),(\d+),([A-Z]),(.*): (.*)]],
                        { line = 1, column = 2, security = 3, message = { 5, }, },
                    },
                    securities = {
                        -- Available securities are { 'error', 'warning', 'hin', 'info' }
                        E = "error",
                        W = "warning",
                        B = "hint",
                        F = "hint",
                        D = "info",
                    },
                },
                phpcs = {
                    command = "./vendor/bin/phpcs",
                    args = {
                        "--report=json",
                        "-s",
                        "-",
                    },
                    rootPatterns = {
                        "composer.json",
                        "composer.lock",
                        "vendor",
                        ".git",
                    },
                    isStdout = true,
                    isStderr = false,
                    debounce = 100,
                    offsetLine = 0,
                    offsetColumn = 0,
                    sourceName = "phpcs",

                    -- Alternative to JSON parsing,
                    -- requires --report=emacs
                    -- formatLines = 1,
                    -- formatPattern = {
                    --     [[^.*:(\d+):(\d+): (.*) [-] (.*)$]],
                    --     {
                    --         line = 1,
                    --         column = 2,
                    --         security = 3,
                    --         message = { 4, },
                    --     },
                    -- },
                    -- securities = {
                    --     error = "error",
                    --     warning = "warning",
                    -- },

                    parseJson = {
                        errorsRoot = "files.STDIN.messages",
                        line = "line",
                        column = "column",
                        security = "type",
                        message = "${message} (${source})",
                    },
                    securities = {
                        ERROR = "error",
                        WARNING = "warning",
                    },
                },
            },
            formatFiletypes = {
                -- python = { "black", "isort", },
                sh = { "shfmt", },
                bash = { "shfmt", },
                zsh = { "shfmt", },
                -- php = { "php_cs_fixer", },
            },
            formatters = {
                autopep8 = {
                    command = "autopep8",
                    args = {
                        "--aggressive",
                        "-",
                    },
                    rootPatterns = { "Pipfile", "tox.ini", ".git", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                black = {
                    command = "black",
                    args = {
                        "--line-length", "100",
                        "--stdin-filename",
                        "%filename",
                        "--quiet",
                        "-code",
                        "%text",
                    },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                isort = {
                    command = "isort",
                    args = { "--quiet", "-", },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                shfmt = {
                    command = "shfmt",
                    args = { "-s", "-i", "4", "-ci", },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                phpcbf = {
                    command = "./vendor/bin/phpcbf",
                    args = {
                        "--standard=PSR12",
                        "-",
                    },
                    rootPatterns = {
                        "composer.json",
                        "composer.lock",
                        "vendor",
                        ".git",
                    },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = true,
                },
                php_cs_fixer = {
                    command = "./vendor/bin/php-cs-fixer",
                    args = {
                        "fix",
                        "--no-ansi",
                        "--using-cache=no",
                        "--quiet",
                        "--no-interaction",
                        "%file",
                    },
                    isStdout = false,
                    isStderr = false,
                    doesWriteToFile = true,
                    ignoreExitCode = true,
                    rootPatterns = {
                        "composer.json",
                        "composer.lock",
                        "vendor",
                        ".git",
                    },
                },
            },
        },
    },
}
