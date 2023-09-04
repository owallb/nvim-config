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

-- https://github.com/nvim-treesitter/nvim-treesitter

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "c",
        "cmake",
        "comment",
        "cpp",
        "css",
        "csv",
        -- "d", -- requires treesitter cli?
        "diff",
        "dockerfile",
        "doxygen",
        "dtd",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "groovy",
        "hare",
        "html",
        "ini",
        "java",
        "javascript",
        "json",
        "json5",
        "jsonc",
        "latex",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "meson",
        "ninja",
        "norg",
        "odin",
        "perl",
        "php",
        "phpdoc",
        "pymanifest",
        "python",
        "regex",
        "requirements",
        "robot",
        "rst",
        "rust",
        "sql",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "yang",
        "zig",
    },

    -- Indentation based on treesitter for the = operator.
    -- NOTE: This is an experimental feature.
    indent = {
        enable = true,
    },
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
