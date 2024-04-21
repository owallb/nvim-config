-- https://github.com/lewis6991/gitsigns.nvim

---@type LazyPluginSpec
return {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = "VimEnter",
    opts = {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            vim.keymap.set("n", "<leader>gv", gs.select_hunk, { buffer = bufnr })
            vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr })
            vim.keymap.set(
                "x",
                "<leader>gs",
                function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end,
                { buffer = bufnr }
            )
            vim.keymap.set({ "n", "x" }, "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr })
            vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr })
            vim.keymap.set("x", "<leader>gr", ":Gitsigns reset_hunk<CR>", { buffer = bufnr })
            vim.keymap.set("n", "<leader>g?", gs.preview_hunk, { buffer = bufnr })
            vim.keymap.set(
                "n",
                "<leader>gb",
                function()
                    gs.blame_line { full = true, ignore_whitespace = true }
                end,
                { buffer = bufnr }
            )
            vim.keymap.set(
                { "n", "x" },
                "]g", function()
                    gs.next_hunk({
                        wrap = true,
                        navigation_message = true,
                        foldopen = true,
                        preview = true,
                    })
                end
            )
            vim.keymap.set(
                { "n", "x" },
                "[g", function()
                    gs.prev_hunk({
                        wrap = true,
                        navigation_message = true,
                        foldopen = true,
                        preview = true,
                    })
                end
            )
        end,
        signs = {
            untracked = { text = "│" },
        },
    },
}
