vim.loader.enable()

---@type LazyPluginSpec[]
local plugins = {
    {
        "bluz71/vim-moonfly-colors",
        priority = 1000,
        lazy = false,
        name = "moonfly",
        config = require("plugins.moonfly"),
    },
    --[[ {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 100,
        lazy = false,
        config = require("plugins.catppuccin"),
    }, ]]
    --[[ {
        "navarasu/onedark.nvim",
        priority = 1000,
        lazy = false,
        -- name = "moonfly",
        config = require("plugins.onedark"),
    }, ]]
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
        "saadparwaiz1/cmp_luasnip",
    },
    {
        "hrsh7th/cmp-path",
    },
    {
        "hrsh7th/cmp-cmdline",
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
        "neovim/nvim-lspconfig",
        config = require("lsp").setup,
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
    },
    {
        "rcarriga/nvim-dap-ui",
        config = require("plugins.dap_ui"),
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
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
        "nvim-telescope/telescope-fzf-native.nvim",
        build =
            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release" ..
            " && cmake --build build --config Release" ..
            " && cmake --install build --prefix build",
    },
    {
        "numToStr/Comment.nvim",
        config = require("plugins.comment"),
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
        "dstein64/vim-startuptime",
        lazy = true,
        event = "VimEnter",
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
    {
        "cbochs/grapple.nvim",
        dependencies = { "nvim-lua/plenary.nvim", },
        config = require("plugins.grapple"),
    },
    {
        "is0n/fm-nvim",
        config = require("plugins.fm-nvim"),
    },
    {
        "NvChad/nvim-colorizer.lua",
        config = require("plugins.nvim-colorizer"),
    },
}

local opts = {
    install = {
        colorscheme = { "moonfly", },
    },
}

require("lazy").setup(plugins, opts)
