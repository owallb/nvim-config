vim.loader.enable()

local utils = require("ow.utils")

local files = {
    "globals",
    "options",
    "autocommands",
    "mappings",
}

for _, file in ipairs(files) do
    local pkg = "ow.core." .. file
    local ok, err = pcall(require, pkg)
    if not ok then
        utils.err("Error while loading package " .. pkg)
        utils.err(err)
        return
    end
end

local ok, err = pcall(require, "ow.bootstrap")
if not ok then
    utils.err("Error during bootstrap")
    utils.err(err:gsub("\t", "  "))
    return
end

---@type LazyPluginSpec[]
local plugins = {
    {
        "neovim/nvim-lspconfig",
        config = require("ow.lsp").setup,
    },
    { import = "ow.plugins" },
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
