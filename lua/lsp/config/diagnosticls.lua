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
            lua = { "luaFormatter", },
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
            luaFormatter = {
                sourceName = "luaFormatter",
                command = "lua-format",
                isStdout = true,
                isStderr = false,
                ignoreExitCode = false,
                args = {
                    "--column-limit",
                    "80",                                   -- Column limit of one line
                    "--indent-width",
                    "4",                                    -- Number of spaces used for indentation
                    -- '--use-tab', -- Use tab for indentation
                    "--no-use-tab",                         -- Do not use tab for indentation
                    "--tab-width",
                    "4",                                    -- Number of spaces used per tab
                    "--continuation-indent-width",
                    "4",                                    -- Indent width for continuations line
                    "--spaces-before-call",
                    "1",                                    -- Space on function calls
                    "--keep-simple-control-block-one-line", -- Keep block in one line
                    -- '--no-keep-simple-control-block-one-line', -- Do not keep block in one line
                    "--keep-simple-function-one-line",      -- Keep function in one line
                    -- '--no-keep-simple-function-one-line', -- Do not keep function in one line
                    "--align-args",                         -- Align the arguments
                    -- '--no-align-args', -- Do not align the arguments
                    "--break-after-functioncall-lp",        -- Break after '(' of function call
                    -- '--no-break-after-functioncall-lp', -- Do not break after '(' of function call
                    "--break-before-functioncall-rp",       -- Break before ')' of function call
                    -- '--no-break-before-functioncall-rp', -- Do not break before ')' of function call
                    -- '--spaces-inside-functioncall-parens', -- Put spaces on the inside of parens in function calls
                    "--no-spaces-inside-functioncall-parens", -- Do not put spaces on the inside of parens in function calls
                    -- '--spaces-inside-functiondef-parens', -- Put spaces on the inside of parens in function headers
                    "--no-spaces-inside-functiondef-parens",  -- Do not put spaces on the inside of parens in function headers
                    "--align-parameter",                      -- Align the parameters
                    -- '--no-align-parameter', -- Do not align the parameters
                    "--chop-down-parameter",                  -- Chop down all parameters
                    -- '--no-chop-down-parameter', -- Do not chop down all parameters
                    "--break-after-functiondef-lp",           -- Break after '(' of function def
                    -- '--no-break-after-functiondef-lp', -- Do not break after '(' of function def
                    "--break-before-functiondef-rp",          -- Break before ')' of function def
                    -- '--no-break-before-functiondef-rp', -- Do not break before ')' of function def
                    "--align-table-field",                    -- Align fields of table
                    -- '--no-align-table-field', -- Do not align fields of table
                    "--break-after-table-lb",                 -- Break after '{' of table
                    -- '--no-break-after-table-lb', -- Do not break after '{' of table
                    "--break-before-table-rb",                -- Break before '}' of table
                    -- '--no-break-before-table-rb', -- Do not break before '}' of table
                    "--chop-down-table",                      -- Chop down any table
                    -- '--no-chop-down-table', -- Do not chop down any table
                    "--chop-down-kv-table",                   -- Chop down table if table contains key
                    -- '--no-chop-down-kv-table', -- Do not chop down table if table contains key
                    "--table-sep",
                    ",",                              -- Character to separate table fields
                    "--column-table-limit",
                    "80",                             -- Column limit of each line of a table
                    -- '--extra-sep-at-table-end', -- Add a extra field separator
                    "--no-extra-sep-at-table-end",    -- Do not add a extra field separator
                    "--spaces-inside-table-braces",   -- Put spaces on the inside of braces in table constructors
                    -- '--no-spaces-inside-table-braces', -- Do not put spaces on the inside of braces in table constructors
                    "--break-after-operator",         -- Put break after operators
                    -- '--no-break-after-operator', -- Do not put break after operators
                    "--double-quote-to-single-quote", -- Transform string literals to use single quote
                    -- '--no-double-quote-to-single-quote', -- Do not transform string literals to use single quote
                    -- '--single-quote-to-double-quote', -- Transform string literals to use double
                    "--no-single-quote-to-double-quote", -- Do not transform string literals to use double
                    "--spaces-around-equals-in-field",   -- Put spaces around the equal sign in key/value fields
                    -- '--no-spaces-around-equals-in-field', -- Do not put spaces around the equal sign in key/value fields
                    "--line-breaks-after-function-body",
                    "1",    -- Line brakes after function body
                    "--line-separator",
                    "input", -- input(determined by the input content),
                    -- os(Use line ending of the current Operating system),
                    -- lf(Unix style "\n"),
                    -- crlf(Windows style "\r\n"),
                    -- cr(classic Max style "\r")
                },
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
}
