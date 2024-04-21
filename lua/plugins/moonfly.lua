-- https://github.com/bluz71/vim-moonfly-colors

---@type LazyPluginSpec
return {
    "bluz71/vim-moonfly-colors",
    priority = 1000,
    lazy = false,
    name = "moonfly",
    init = function()
        vim.g.moonflyNormalFloat = true
        vim.g.moonflyCursorColor = true
        vim.g.moonflyWinSeparator = 2
    end,
    config = function()
        vim.cmd.colorscheme("moonfly")
    end,
}
