-- https://github.com/fedepujol/move.nvim

-- TODO: figure out how to add "silent" to keymaps
---@type LazyPluginSpec
return {
    "fedepujol/move.nvim",
    keys = {
        { "<A-j>", function() vim.cmd.MoveLine(1) end,    mode = "n" },
        { "<A-k>", function() vim.cmd.MoveLine(-1) end,   mode = "n" },
        { "<A-h>", function() vim.cmd.MoveHChar(-1) end,  mode = "n" },
        { "<A-l>", function() vim.cmd.MoveHChar(1) end,   mode = "n" },
        { "<A-j>", ":MoveBlock(1)<CR>",                   mode = "x" },
        { "<A-k>", ":MoveBlock(-1)<CR>",                  mode = "x" },
        { "<A-h>", ":MoveHBlock(-1)<CR>",                 mode = "x" },
        { "<A-l>", ":MoveHBlock(1)<CR>",                  mode = "x" },
    },
    opts = {
        char = {
            enable = true,
        },
    },
}
