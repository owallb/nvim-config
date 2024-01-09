-- https://github.com/bluz71/vim-moonfly-colors

local function setup()
    vim.g.moonflyNormalFloat = true
    vim.g.moonflyCursorColor = true
    vim.g.moonflyWinSeparator = 2

    vim.cmd.colorscheme("moonfly")
end

return setup
