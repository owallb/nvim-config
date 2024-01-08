-- https://github.com/lewis6991/gitsigns.nvim

local function setup()
    require("gitsigns").setup({
        on_attach = function (bufnr)
            local gs = package.loaded.gitsigns
            vim.keymap.set("n", "<leader>gv", gs.select_hunk, { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk,
                { buffer = bufnr, })
            vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, })
            vim.keymap.set(
                "x",
                "<leader>gr",
                ":Gitsigns reset_hunk<CR>",
                { buffer = bufnr, }
            )
            vim.keymap.set("n", "<leader>g?", gs.preview_hunk,
                { buffer = bufnr, })
            vim.keymap.set(
                "n",
                "<leader>gb",
                function ()
                    gs.blame_line { full = true, ignore_whitespace = true, }
                end,
                { buffer = bufnr, })
        end,
        signs = {
            untracked = { text = "│", },
        },
    })
end

return setup
