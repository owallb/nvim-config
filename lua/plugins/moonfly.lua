-- https://github.com/bluz71/vim-moonfly-colors

local utils = require("utils")

local function override_hl(hl_name, opts)
    local hl = vim.api.nvim_get_hl(0, { name = hl_name, })
    utils.update_table(hl, opts)
    vim.api.nvim_set_hl(0, hl_name, hl)
end

local function setup()
    vim.g.moonflyNormalFloat = true
    vim.g.moonflyCursorColor = true
    vim.g.moonflyWinSeparator = 2

    local custom_highlight = vim.api.nvim_create_augroup(
        "CustomMoonflyHighlight", {})
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "moonfly",
        callback = function ()
            override_hl("DiffAdd", { bg = "#364143", })
            override_hl("DiffText", { bg = "#3e4b6b", })
            override_hl("DiffChange", { bg = "#25293c", })
            override_hl("DiffDelete", { bg = "#443244", })
        end,
        group = custom_highlight,
    })

    vim.cmd.colorscheme("moonfly")
end

return setup
