vim.fn.sign_define("QfError", { text = "E", texthl = "DiagnosticError" })
vim.fn.sign_define("QfWarn", { text = "W", texthl = "DiagnosticWarn" })
vim.fn.sign_define("QfInfo", { text = "I", texthl = "DiagnosticInfo" })
vim.fn.sign_define("QfNote", { text = "N", texthl = "DiagnosticHint" })

vim.api.nvim_create_autocmd("FileType", {
    desc = "Add signs to quickfix entries",
    pattern = "qf",
    callback = function(event)
        vim.fn.sign_unplace("quickfix_signs")
        local qflist = vim.fn.getqflist()
        require("log").debug(vim.inspect(qflist))
        for i, item in ipairs(qflist) do
            if item.valid == 1 then
                local sign_name = nil
                if item.type == "E" then
                    sign_name = "QfError"
                elseif item.type == "W" then
                    sign_name = "QfWarn"
                elseif item.type == "I" then
                    sign_name = "QfInfo"
                elseif item.type == "N" then
                    sign_name = "QfNote"
                end

                if sign_name then
                    vim.fn.sign_place(
                        0,
                        "quickfix_signs",
                        sign_name,
                        event.buf,
                        { lnum = i }
                    )
                end
            end
        end
    end,
})

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
    pattern = { "c" },
    callback = function()
        vim.o.errorformat = "%-Gmake: *** [Makefile:,"
        .. "%-Gg%\\?make[%*\\d]: *** [%f:%l:%m,"
        .. "%-Gg%\\?make: *** [%f:%l:%m,"
        .. "%-G%f:%l: (Each undeclared identifier is reported only once,"
        .. "%-G%f:%l: for each function it appears in.),"
        .. "%-GIn file included from %f:%l:%c:,"
        .. "%-GIn file included from %f:%l:%c\\,,"
        .. "%-GIn file included from %f:%l:%c,"
        .. "%-GIn file included from %f:%l,"
        .. "%-G%*[ ]from %f:%l:%c,"
        .. "%-G%*[ ]from %f:%l:,"
        .. "%-G%*[ ]from %f:%l\\,,"
        .. "%-G%*[ ]from %f:%l,"
        .. "%-G%f:%l:%c: note: '%*[^']' declared here,"
        .. "%D%*\\a[%*\\d]: Entering directory %*[`']%f',"
        .. "%X%*\\a[%*\\d]: Leaving directory %*[`']%f',"
        .. "%D%*\\a: Entering directory %*[`']%f',"
        .. "%X%*\\a: Leaving directory %*[`']%f',"
        .. "%DMaking %*\\a in %f,"
        .. "%f:%l:%c: %t%*[^:]: %m,"
        .. "%*[^:]: %f:%l: %m,"
        .. "%-G%.%#"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.wo.colorcolumn = "0"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "rust" },
    callback = function()
        vim.bo.errorformat = "%Enote: test %m at %f:%l:%c,"
        .. "%E%\\%%(%.%#panicked%\\)%\\@=%m at %f:%l:%c:,"
        .. "%-Gerror: test failed\\, %.%#,"
        .. "%-G%*[^:]: %.%# generated %*\\d %.%#,"
        .. "%-Gnote: run with `RUST_BACKTRACE=%.%#,"
        .. "%-G%\\s%#Running%.%#,"
        .. vim.bo.errorformat:gsub(
            "%%E  left:%%m,%%C right:%%m %%f:%%l:%%c,",
            ""
        )
    end,
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
        vim.opt_local.indentkeys:remove("<:>")
    end,
})

vim.api.nvim_create_autocmd("TermLeave", {
    desc = "Reload buffers when leaving terminal",
    pattern = "*",
    callback = function()
        vim.cmd.checktime()
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "vim", "help" },
    callback = function(args)
        vim.keymap.set("n", "K", function()
            vim.cmd("help " .. vim.fn.expand("<cexpr>"))
        end, { buffer = args.buf })
    end,
})
