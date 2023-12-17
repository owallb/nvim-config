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

vim.loader.enable()

local plugins = {
    {
        "bluz71/vim-moonfly-colors",
        priority = 1000,
        lazy = false,
        name = "moonfly",
        config = require("plugins.moonfly"),
    },
    {
        "rcarriga/nvim-notify",
        priority = 900,
        lazy = false,
        config = require("plugins.notify"),
    },
    {
        "rafamadriz/friendly-snippets",
    },
    {
        "L3MON4D3/LuaSnip",
        config = require("plugins.luasnip"),
        -- comment out on windows and install jsregexp manually
        build = (
            require("utils").os_name ~= "Windows_NT"
            and "make install_jsregexp"
            or nil
        ),
        version = "2.*",
    },
    {
        "windwp/nvim-autopairs",
        config = require("plugins.autopairs"),
    },
    {
        "saadparwaiz1/cmp_luasnip",
    },
    {
        "hrsh7th/cmp-buffer",
    },
    {
        "hrsh7th/cmp-path",
    },
    {
        "hrsh7th/cmp-cmdline",
    },
    {
        "hrsh7th/cmp-nvim-lua",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "hrsh7th/nvim-cmp",
        config = require("plugins.cmp"),
    },
    {
        "onsails/lspkind.nvim",
        config = require("plugins.lspkind"),
    },
    {
        "williamboman/mason.nvim",
        config = require("plugins.mason"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = require("plugins.mason_lspconfig"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "neovim/nvim-lspconfig",
        config = require("lsp").setup,
        lazy = true,
        ft = require("lsp").filetypes(),
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = require("plugins.treesitter"),
        build = ":TSUpdate",
        lazy = true,
        event = "VimEnter",
    },
    {
        "mfussenegger/nvim-dap",
        config = require("plugins.dap").setup,
        lazy = true,
        ft = require("lsp").filetypes(),
    },
    {
        "rcarriga/nvim-dap-ui",
        config = require("plugins.dap_ui"),
        dependencies = {
            "mfussenegger/nvim-dap",
        },
    },
    {
        "tpope/vim-fugitive",
        config = require("plugins.fugitive"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "rbong/vim-flog",
        config = require("plugins.flog"),
    },
    {
        "nvim-lualine/lualine.nvim",
        config = require("plugins.lualine"),
        lazy = true,
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        config = require("plugins.gitsigns"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "nvim-telescope/telescope.nvim",
        config = require("plugins.telescope"),
        lazy = true,
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "numToStr/Comment.nvim",
        config = require("plugins.comment"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = require("plugins.indent-blankline"),
        lazy = true,
        event = "VimEnter",
    },
    {
        "simeji/winresizer",
        config = require("plugins.winresizer"),
        lazy = true,
        keys = { "<C-W>r", },
    },
    {
        "sindrets/winshift.nvim",
        config = require("plugins.winshift"),
        lazy = true,
        keys = { "<C-W>m", },
    },
    {
        "martinda/Jenkinsfile-vim-syntax",
        lazy = true,
        ft = { "jenkinsfile", "Jenkinsfile", },
    },
    {
        "dstein64/vim-startuptime",
        lazy = true,
        event = "VimEnter",
    },
    {
        "simrat39/symbols-outline.nvim",
        config = require("plugins.symbols-outline"),
    },
    {
        "RubixDev/mason-update-all",
        config = require("plugins.mason_update_all"),
    },
    {
        "famiu/bufdelete.nvim",
        config = require("plugins.bufdelete"),
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = require("plugins.treesitter-context"),
    },
    {
        "fedepujol/move.nvim",
        config = require("plugins.move"),
    },
    {
        "nvim-orgmode/orgmode",
        config = require("plugins.orgmode"),
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "farmergreg/vim-lastplace",
    },
    {
        "sindrets/diffview.nvim",
        config = require("plugins.diffview"),
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        config = require("plugins.markdown-preview"),
    },
    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "LspAttach",
        config = require("plugins.fidget"),
    },
    {
        "lvimuser/lsp-inlayhints.nvim",
        branch = "anticonceal",
        config = require("plugins.lsp-inlayhints"),
    },
}

local opts = {
    install = {
        colorscheme = { "moonfly" }
    }
}

require("lazy").setup(plugins, opts)
