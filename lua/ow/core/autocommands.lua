vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = true
    end,
})

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
        vim.bo.errorformat = "%f:%l:%c: %t%.%#: %m,%-G%.%#"
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    desc = "Return cursor to last position when re-opening a buffer",
    pattern = "*",
    command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Use two space indent for C++ files",
    pattern = { "cpp" },
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.cinoptions = "g0"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "netrw" },
    callback = function()
        vim.keymap.set("n", "<C-h>", "-", { buffer = true, remap = true })
        vim.keymap.set("n", "<C-l>", "<CR>", { buffer = true, remap = true })
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    command = ":clearjumps",
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Customize python indentation",
    pattern = { "python" },
    callback = function()
        vim.g.python_indent = {
            open_paren = 'shiftwidth()',
            continue = 'shiftwidth()',
            closed_paren_align_last_line = false,
        }
    end,
})

