---@type LazyPluginSpec
return {
    "owallb/mason-auto-install.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    ---@type MasonAutoInstall.Config
    opts = {
        packages = {
            {
                "bash-language-server",
                dependencies = { "shellcheck", "shfmt" },
            },
            -- "clangd",
            {
                "cmake-language-server",
                dependencies = { "golines" },
            },
            "gopls",
            {
                "intelephense",
                dependencies = { "phpcs" },
            },
            "jedi-language-server",
            {
                "lemminx",
                dependencies = { "xmlformatter" },
            },
            {
                "lua-language-server",
                dependencies = { "stylua" },
            },
            "mesonlsp",
            "ruff",
            "pyright",
            "pyrefly",
            "rust-analyzer",
            "zls",
        },
    },
}
