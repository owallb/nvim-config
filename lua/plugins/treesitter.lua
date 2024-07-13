-- https://github.com/nvim-treesitter/nvim-treesitter

---@type LazyPluginSpec[]
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = true,
        event = "VimEnter",
        opts = {
            ensure_installed = {
                "c", -- recommended default
                "lua", -- recommended default
                "vim", -- recommended default
                "vimdoc", -- recommended default
                "query", -- recommended default
                "luadoc",
                "phpdoc",
                "org",
                "comment",
            },
            auto_install = true,
            highlight = {
                enable = true,
                disable = {},

                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = { "org", "php", "python" },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)

            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldenable = true

            -- Disable LSP semantic highlighting for comments because it will otherwise
            -- override highlights from `comment`.
            vim.api.nvim_set_hl(0, "@lsp.type.comment", {})

            -- To set the priority of semantic highlighting lower than treesitter (100),
            -- uncomment the line below:
            -- vim.highlight.priorities.semantic_tokens = 99
        end,
    },
}
