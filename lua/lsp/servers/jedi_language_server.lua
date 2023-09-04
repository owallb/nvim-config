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
    lspconfig = {
        filetypes = {
            "python",
        },
        cmd = { "jedi-language-server", },
        single_file_support = true,
        -- For more info see:
        -- - https://github.com/pappasam/jedi-language-server#configuration
        -- - https://github.com/pappasam/coc-jedi#configuration (good descriptions)
        init_options = {
            -- Built-in diagnostics seem to be very basic,
            -- to the point where you are wondering if it's even active.
            -- Will use iamcco/diagnostic-languageserver instead.
            diagnostics = {
                -- Enables (or disables) diagnostics provided by Jedi
                -- type: boolean
                -- default: true
                enable = false,
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
                        ".nox", ".tox", ".venv", "__pycache__", "venv",
                        "artifacts", "config", ".vscode", ".pytest_cache",
                        "build", "scripts", "incoax_tests.egg-info",
                        "node_modules",
                    },
                },
            },
        },
    },
}
