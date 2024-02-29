-- https://github.com/nvim-treesitter/nvim-treesitter

local function setup()
    require("nvim-treesitter.configs").setup({
        ensure_installed = {
            "c",      -- recommended default
            "lua",    -- recommended default
            "vim",    -- recommended default
            "vimdoc", -- recommended default
            "query",  -- recommended default
            "luadoc",
            "phpdoc",
            "regex",           -- for noice
            "bash",            -- for noice
            "markdown",        -- for noice
            "markdown_inline", -- for noice
            "org",
        },
        auto_install = true,

        highlight = {
            enable = true,
            disable = {},

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = { "org", "php" },
        },
    })

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = true
end

return setup
