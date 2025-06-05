---@type LazyPluginSpec
return {
    "owallb/mason-auto-install.nvim",
    ---@type MasonAutoInstall.Config
    opts = {
        packages = {
            {
                "bash-language-server",
                filetypes = { "sh", "bash", "zsh" },
                dependencies = { "shellcheck", "shfmt" },
            },
            -- "clangd",
            {
                "cmake-language-server",
                dependencies = {
                    { "golines" },
                },
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
                post_install_hooks = {
                    { "cargo", "install", "stylua", "--features", "lua54" },
                },
            },
            "mesonlsp",
            "ruff" ,
            "pyright",
            "pyrefly",
            "rust-analyzer",
            "zls",
        },
    },
}
