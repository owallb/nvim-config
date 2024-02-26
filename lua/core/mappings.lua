--- Tab mappings ---
vim.keymap.set("n", "tn", vim.cmd.tabnew)
vim.keymap.set("n", "tq", vim.cmd.tabclose)
-- switch tabs with Ctrl+PgUp/Ctrl+PgDwn (default vim mapping)

--- Buffer mappings ---
-- Center cursorline
vim.keymap.set("n", "<leader><leader>", "zz")
-- Save buffer
vim.keymap.set("n", "<C-s>", function ()
    vim.cmd.write({ mods = { silent = true, }, })
end)
-- Cycle buffers
-- TODO: change to :bnext and :bprev
vim.keymap.set("n", "<C-End>", vim.cmd.bnext)
vim.keymap.set("n", "<C-Home>", vim.cmd.bprev)

--- Navigation ---
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--- General mappings ---
-- yank/put using named register
vim.keymap.set({ "n", "x", }, "<leader>y", '"+y')
vim.keymap.set({ "n", "x", }, "<leader>p", '"+p')
vim.keymap.set({ "n", "x", }, "<leader>P", '"+P')
vim.keymap.set({ "n", "x", }, "<leader>+", function ()
    vim.fn.setreg("+", vim.fn.getreg('"'))
end)

-- Allow exiting insert mode in terminal by hitting <ESC>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Use :diffput/get instead of normal one to allow staging visual selection
vim.keymap.set("n", "<leader>dp", vim.cmd.diffput)
vim.keymap.set("x", "<leader>dp", ":diffput<CR>")
vim.keymap.set("n", "<leader>do", vim.cmd.diffget)
vim.keymap.set("x", "<leader>do", ":diffget<CR>")
vim.keymap.set("i", "<C-e>", vim.cmd.fclose)

-- Remove default mappings
vim.keymap.set("", "<C-LeftMouse>", "")

-- Remove right-click menu items
vim.cmd.aunmenu({ "PopUp.-1-", })
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse", })
