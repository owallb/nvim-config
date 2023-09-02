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
    cmd = { "pylsp", },
    single_file_support = true,
    -- Reference: https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    settings = {
        pylsp = {
            -- configurationSources = { "flake8", "jedi_completion", "jedi_definition", "jedi_hover", "jedi_references", "jedi_signature_help", "jedi_symbols" },
            plugins = {
                flake8 = {
                    config = "tox.ini",
                    enabled = true,
                    -- executable = "flake8"
                },
                pyls_isort = { enabled = true, },
                jedi_completion = {
                    enabled = true,
                    include_params = false,
                    include_class_objects = true,
                    fuzzy = true,
                    eager = true,
                    resolve_at_most = 25,
                    cache_for = {
                        "pandas",
                        "numpy",
                        "tensorflow",
                        "matplotlib",
                    },
                },
                jedi_definition = {
                    enabled = true,
                    follow_imports = true,
                    follow_builtin_imports = true,
                },
                jedi_hover = { enabled = true, },
                jedi_references = { enabled = true, },
                jedi_signature_help = { enabled = true, },
                jedi_symbols = {
                    enabled = true,
                    all_scopes = true,
                    include_import_symbols = true,
                },
            },
        },
    },
}
