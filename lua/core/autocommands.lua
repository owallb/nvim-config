vim.api.nvim_create_autocmd("FileType", {
    desc = "Use tabs for indents in Go files",
    pattern = "go",
    callback = function()
        vim.bo.expandtab = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Fix parsing compile errors into quickfixlist",
    pattern = "zig",
    callback = function()
        vim.bo.errorformat = '%f:%l:%c: %t%.%#: %m,%-G%.%#'
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    desc = "Return cursor to last position when re-opening a buffer",
    pattern = "*",
    command = 'silent! normal! g`"zv',
})
