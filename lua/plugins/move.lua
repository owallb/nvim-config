-- https://github.com/fedepujol/move.nvim

local function setup()
    require("move").setup({
        char = {
            enable = true,
        },
    })

    local opts = { noremap = true, silent = true, }
    vim.keymap.set("n", "<A-j>", function () vim.cmd.MoveLine(1) end, opts)
    vim.keymap.set("n", "<A-k>", function () vim.cmd.MoveLine(-1) end, opts)
    vim.keymap.set("n", "<A-h>", function () vim.cmd.MoveHChar(-1) end, opts)
    vim.keymap.set("n", "<A-l>", function () vim.cmd.MoveHChar(1) end, opts)
    vim.keymap.set("x", "<A-j>", ":MoveBlock(1)<CR>", opts)
    vim.keymap.set("x", "<A-k>", ":MoveBlock(-1)<CR>", opts)
    vim.keymap.set("x", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
    vim.keymap.set("x", "<A-l>", ":MoveHBlock(1)<CR>", opts)
end

return setup
