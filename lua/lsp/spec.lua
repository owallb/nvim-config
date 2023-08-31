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
    clangd = {
        filetypes = {
            'c',
            'cpp',
            'objc',
            'objcpp',
            'cuda',
            'proto',
        }
    },
    cmake = {
        filetypes = {
            'cmake'
        }
    },
    diagnosticls = {
        filetypes = {
            'python',
            'lua',
            'sh',
        }
    },
    lua_ls = {
        filetypes = {
            'lua'
        }
    },
    lemminx = {
        filetypes = {
            'xml',
            'xsd',
            'xsl',
            'xslt',
            'svg',
        }
    },
    bashls = {
        filetypes = {
            'sh'
        }
    },
    groovyls = {
        filetypes = {
            'groovy'
        }
    },
    rust_analyzer = {
        filetypes = {
            'rust'
        }
    },
    gopls = {
        filetypes = {
            "go",
            "gomod"
        }
    },
    golangci_lint_ls = {
        filetypes = {
            "go",
            "gomod"
        }
    },
    jedi_language_server = {
        filetypes = {
            'python'
        }
    },
    -- pyright = { 'python' },
    -- pylsp = { 'python' },
}
