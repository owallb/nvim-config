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
    cmd = { "jedi-language-server", },
    single_file_support = true,
    -- For more info see https://github.com/pappasam/jedi-language-server#configurationSources
    -- and https://github.com/pappasam/coc-jedi#configuration (good descriptions)
    init_options = {
        completion = {
            -- If your language client supports CompletionItem snippets but you don't like them,
            -- disable them by setting this option to true.
            -- type: boolean
            -- default: false
            disableSnippets = false,
            -- Return all completion results in initial completion request.
            -- Set to true if your language client does not support completionItem/resolve.
            -- type: boolean
            -- default: false
            resolveEagerly = false,
            -- A list of regular expressions.
            -- If any regular expression in ignorePatterns matches a completion's name,
            -- that completion item is not returned to the client.
            -- type: string[]
            -- default: []
            -- In general, you should prefer the default value for this option.
            -- Jedi is very good at filtering values for end users.
            -- That said, there are situations where IDE developers,
            -- or some programmers in some code bases, may want to filter some completions by name.
            -- This flexible interface is provided to accommodate these advanced use cases.
            ignorePatterns = {},
        },
        -- Built-in diagnostics seem to be very basic,
        -- to the point where you are wondering if it's even active.
        -- Will use iamcco/diagnostic-languageserver instead.
        diagnostics = {
            -- Enables (or disables) diagnostics provided by Jedi
            -- type: boolean
            -- default: true
            enable = false,
            -- When diagnostics are enabled, run on document open
            -- type: boolean
            -- default: true
            didOpen = true,
            -- When diagnostics are enabled, run on in-memory document change
            -- (eg, while you're editing, without needing to save to disk)
            -- type: boolean
            -- default: true
            didChange = true,
            -- When diagnostics are enabled, run on document save (to disk)
            -- type: boolean
            -- default: true
            didSave = true,
        },
        hover = {
            -- Enable (or disable) all hover text.
            -- If set to false, will cause the hover method not to be registered to the language server.
            -- type: boolean
            -- default: true
            enable = true,
            -- disable.[jedi-type].all
            --      Disable all hover text of jedi-type specified.
            --      type: boolean
            --      default: false
            -- disable.[jedi-type].names
            --      Disable hover text identified by name in list of jedi-type specified.
            --      type: string[]
            --      default: []
            -- disable.[jedi-type].fullNames
            --      Disable hover text identified by the fully qualified name in list of jedi-type specified.
            --      If no fully qualified name can be found, jedi-language-server will default to
            --      the name to prevent any unexpected behavior for users
            --      (relevant for jedi types like keywords that don't have full names).
            --      type: string[]
            --      default: []
            disable = {
                class = { all = false, names = {}, fullNames = {}, },
                -- Need to escape lua keyword
                ["function"] = { all = false, names = {}, fullNames = {}, },
                instance = { all = false, names = {}, fullNames = {}, },
                keyword = { all = false, names = {}, fullNames = {}, },
                module = { all = false, names = {}, fullNames = {}, },
                param = { all = false, names = {}, fullNames = {}, },
                path = { all = false, names = {}, fullNames = {}, },
                property = { all = false, names = {}, fullNames = {}, },
                statement = { all = false, names = {}, fullNames = {}, },
            },
        },
        jediSettings = {
            -- Modules that jedi will directly import without analyzing.
            -- Improves autocompletion but loses goto definition.
            -- type: string[]
            -- default: []
            -- If you're noticing that modules like numpy and pandas are taking a super long time to load
            -- and you value completions / signatures over goto definition,
            -- I recommend using this option like this:
            -- autoImportModules = { "numpy", "pandas" },
            autoImportModules = {},
            -- Completions are by default case insensitive.
            -- Set to false to make completions case sensitive.
            -- type: boolean
            -- default: true
            caseInsensitiveCompletion = true,
            -- Print jedi debugging messages to stderr.
            -- type: boolean
            -- default: false
            debug = false,
        },
        -- The preferred MarkupKind for all jedi-language-server messages that take MarkupContent.
        -- type: string
        -- accepted values: "markdown", "plaintext"
        -- If omitted, jedi-language-server defaults to the client-preferred configuration.
        -- If there is no client-preferred configuration, jedi language server users "plaintext".
        -- markupKindPreferred = "markdown",
        workspace = {
            -- Add additional paths for Jedi's analysis.
            -- Useful with vendor directories, packages in a non-standard location, etc.
            -- You probably won't need to use this, but you'll be happy it's here when you need it!
            -- type: string[]
            -- default: []
            -- Non-absolute paths are relative to your project root.
            -- For example, let's say your Python project is structured like this:
            --      ├── funky
            --      │   └── haha.py
            --      ├── poetry.lock
            --      ├── pyproject.toml
            --      └── test.py
            -- Assume that funky/haha.py contains 1 line, x = 12,
            -- and your build system does some wizardry that makes haha importable just like os or pathlib.
            -- In this example, if you want to have this same non-standard behavior with jedi-language-server,
            -- put the following:
            -- extraPaths = { "funky" }
            -- When editing test.py, you'll get completions, goto definition,
            -- and all other lsp features for the line `from haha import ....`
            -- Again, you probably don't need this.
            extraPaths = {},
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
                -- Maximum number of symbols returned by a call to workspace/symbols.
                -- type: number
                -- default: 20
                -- A value less than or equal to zero removes the maximum
                -- and allows jedi-language-server to return all workplace symbols found by jedi.
                maxSymbols = 20,
            },
        },
    },
}
