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

local servers = {
    clangd = {
        enabled = true,
        filetypes = {
            "c",
            "cpp",
            "objc",
            "objcpp",
            "cuda",
            "proto",
        },
        config = {},
    },
    cmake = {
        enabled = true,
        filetypes = {
            "cmake",
        },
        config = {},
    },
    diagnosticls = {
        enabled = true,
        filetypes = {
            "python",
            "lua",
            "sh",
        },
        dependencies = {
            "npm",
        },
        config = {},
    },
    lua_ls = {
        enabled = true,
        filetypes = {
            "lua",
        },
        config = {},
    },
    lemminx = {
        enabled = true,
        filetypes = {
            "xml",
            "xsd",
            "xsl",
            "xslt",
            "svg",
        },
        config = {},
    },
    bashls = {
        enabled = true,
        filetypes = {
            "sh",
        },
        dependencies = {
            "npm",
            "shellcheck"
        },
        config = {},
    },
    groovyls = {
        enabled = true,
        filetypes = {
            "groovy",
        },
        config = {},
    },
    jedi_language_server = {
        enabled = true,
        filetypes = {
            "python",
        },
        config = {},
    },
}

return servers
