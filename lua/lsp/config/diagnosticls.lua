--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

return {
    enabled = true,
    dependencies = {
        "npm",
    },
    lspconfig = {
        filetypes = {
            "python",
            "lua",
            "sh",
        },
        cmd = { "diagnostic-languageserver", "--stdio", },
        single_file_support = true,
        -- For more info see https://github.com/iamcco/diagnostic-languageserver
        init_options = {
            filetypes = { python = "flake8", lua = "luaFormatter", },
            linters = {
                -- some help from this:
                -- https://github.com/creativenull/diagnosticls-configs-nvim/blob/main/lua/diagnosticls-configs/linters/flake8.lua
                flake8 = {
                    command = "flake8",
                    args = {
                        "--config",
                        "tox.ini",
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
                        [[(\d+),(\d+),([A-Z]),(.*)(\r|\n)*$]],
                        { line = 1, column = 2, security = 3, message = { 4, }, },
                    },
                    securities = {
                        -- Available securities are { 'error', 'warning', 'hint', 'info' }
                        E = "error",
                        W = "warning",
                        B = "hint",
                        F = "error",
                        D = "info",
                    },
                },
            },
            formatFiletypes = {
                python = { "black", "isort", },
                sh = { "shfmt", },
            },
            formatters = {
                black = {
                    sourceName = "black",
                    command = "black",
                    args = {
                        "--stdin-filename",
                        "%filename",
                        "-t",
                        "py39",
                        "--quiet",
                        "-",
                    },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                isort = {
                    sourceName = "isort",
                    command = "isort",
                    args = { "--quiet", "-", },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
                shfmt = {
                    sourceName = "shfmt",
                    command = "shfmt",
                    args = { "-s", "-i", "4", "-ci", },
                    rootPatterns = { "Pipfile", ".git", "tox.ini", },
                    isStdout = true,
                    isStderr = false,
                    ignoreExitCode = false,
                },
            },
        },
    },
}
