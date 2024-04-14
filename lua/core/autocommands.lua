vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function ()
        vim.bo.expandtab = false
    end,
})

local custom_highlight = vim.api.nvim_create_augroup("CustomHighlight", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "moonfly",
    callback = function ()
        vim.api.nvim_set_hl(0, "@variable.member", { link = "MoonflyTurquoise", })
    end,
    group = custom_highlight,
})
