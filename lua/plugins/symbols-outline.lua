-- https://github.com/simrat39/symbols-outline.nvim

local function setup()
    local outline = require("symbols-outline")
    outline.setup({
        show_relative_numbers = true,
        keymaps = {
            fold = { "h", "zc", },
            unfold = { "l", "zo", },
            fold_all = "zM",
            unfold_all = "zR",
        },
    })
    vim.keymap.set(
        "n",
        "<leader>ot",
        vim.cmd.SymbolsOutline
    )
end

return setup
