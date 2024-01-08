-- https://github.com/bluz71/vim-moonfly-colors

local function setup()
    vim.g.moonflyNormalFloat = true
    vim.g.moonflyCursorColor = true
    vim.g.moonflyWinSeparator = 2

    local custom_highlight = vim.api.nvim_create_augroup("CustomMoonflyHighlight", {})
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "moonfly",
        callback = function ()
            vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#364143" })
            vim.api.nvim_set_hl(0, "DiffText", { bg = "#3e4b6b" })
            vim.api.nvim_set_hl(0, "DiffChange", { bg = "#25293c" })
            vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#443244" })
        end,
        group = custom_highlight,
    })

    vim.cmd.colorscheme("moonfly")
end

return setup
