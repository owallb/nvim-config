---@type LazyPluginSpec
return {
    "neovim/nvim-lspconfig",
    config = require("ow.lsp").setup,
}
