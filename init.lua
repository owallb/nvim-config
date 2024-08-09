vim.loader.enable()

local utils = require("utils")

local files = {
    "env",
    "globals",
    "options",
    "autocommands",
    "mappings",
    "user_commands",
}

for _, file in ipairs(files) do
    local pkg = "core." .. file
    local ok, err = pcall(require, pkg)
    if not ok then
        utils.err("Error while loading package " .. pkg)
        utils.err(err)
        return
    end
end

if vim.g.vscode then
    -- VSCode extension
else
    local ok, err = pcall(require, "bootstrap")
    if not ok then
        utils.err("Error during bootstrap")
        utils.err(err:gsub("\t", "  "))
        return
    end

    ---@type LazyPluginSpec[]
    local plugins = {
        {
            "neovim/nvim-lspconfig",
            config = require("lsp").setup,
        },
        { import = "plugins" },
    }

    ---@type LazyConfig
    local opts = {
        install = {
            colorscheme = { "moonfly" },
        },
        ui = {
            icons = {
                cmd = "",
                config = "",
                event = "",
                favorite = "",
                ft = "",
                init = "",
                import = "",
                keys = "",
                lazy = "",
                loaded = "",
                not_loaded = "",
                plugin = "",
                runtime = "",
                require = " ",
                source = "",
                start = "",
                task = "",
                list = {
                    "",
                    "",
                    "",
                    "",
                },
            },
        },
    }

    require("lazy").setup(plugins, opts)
end
