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
        "catppuccin/nvim",
        priority = 1000,
        lazy = false,
        name = "catppuccin",
        config = function ()
            require("plugins.config.catppuccin")
        end,
    },
    {
        "rcarriga/nvim-notify",
        priority = 900,
        lazy = false,
        config = function () require("plugins.config.notify") end,
    },
    {
        "rafamadriz/friendly-snippets",
    },
    {
        "L3MON4D3/LuaSnip",
        config = function () require("plugins.config.luasnip") end,
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
        config = function () require("plugins.config.autopairs") end,
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
        config = function () require("plugins.config.cmp") end,
    },
    {
        "onsails/lspkind.nvim",
        config = function () require("plugins.config.lspkind") end,
    },
    {
        "williamboman/mason.nvim",
        config = function () require("plugins.config.mason") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function () require("plugins.config.mason_lspconfig") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "neovim/nvim-lspconfig",
        config = function () require("lsp"):setup() end,
        lazy = true,
        ft = require("lsp"):filetypes(),
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = function () require("plugins.config.treesitter") end,
        build = ":TSUpdate",
        lazy = true,
        event = "VimEnter",
    },
    {
        "mfussenegger/nvim-dap",
        config = function () require("plugins.config.dap") end,
        lazy = true,
        ft = require("lsp"):filetypes(),
    },
    {
        "rcarriga/nvim-dap-ui",
        config = function () require("plugins.config.dap_ui") end,
        dependencies = {
            "mfussenegger/nvim-dap",
        },
    },
    {
        "tpope/vim-fugitive",
        config = function () require("plugins.config.fugitive") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "rbong/vim-flog",
        config = function () require("plugins.config.flog") end,
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function () require("plugins.config.lualine") end,
        lazy = true,
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function () require("plugins.config.gitsigns") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "nvim-telescope/telescope.nvim",
        config = function () require("plugins.config.telescope") end,
        lazy = true,
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "numToStr/Comment.nvim",
        config = function () require("plugins.config.comment") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function () require("plugins.config.indent-blankline") end,
        lazy = true,
        event = "VimEnter",
    },
    {
        "simeji/winresizer",
        config = function () require("plugins.config.winresizer") end,
        lazy = true,
        keys = { "<C-W>r", },
    },
    {
        "sindrets/winshift.nvim",
        config = function () require("plugins.config.winshift") end,
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
        "stevearc/aerial.nvim",
        config = function () require("plugins.config.aerial") end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
    },
    {
        "RubixDev/mason-update-all",
        config = function () require("plugins.config.mason_update_all") end,
    },
    {
        "famiu/bufdelete.nvim",
        config = function () require("plugins.config.bufdelete") end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function () require("plugins.config.treesitter-context") end,
    },
    {
        "fedepujol/move.nvim",
        config = function () require("plugins.config.move") end,
    },
    {
        "folke/noice.nvim",
        -- see issue https://github.com/folke/lazy.nvim/issues/1038
        -- event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function () require("plugins.config.noice") end,
    },
    {
        "nvim-orgmode/orgmode",
        config = function () require("plugins.config.orgmode") end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "farmergreg/vim-lastplace",
    },
    {
        "sindrets/diffview.nvim",
        config = function () require("plugins.config.diffview") end,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },
}

local opts = {}

require("lazy").setup(plugins, opts)
