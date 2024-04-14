vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function ()
        vim.bo.expandtab = false
    end,
})
